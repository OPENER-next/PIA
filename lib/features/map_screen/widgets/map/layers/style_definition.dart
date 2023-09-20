// When editing these layers, styles and filters always use the new expression syntax
// more info here https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/
// not the old one: https://docs.mapbox.com/mapbox-gl-js/style-spec/other/#other-filter
// Otherwise if errors like 'Invalid filter value: filter property must be a string' may occur
// when both syntaxes are mixed.

const commonPoi = {
  'type': 'symbol',
  'source-layer': 'poi',
  'layout': {
    'icon-image': [
      'coalesce',
      [
        'image',
        ['concat', ['literal', 'indoorequal-'], ['get', 'subclass']]
      ],
      ['image', ['concat', ['literal', 'indoorequal-'], ['get', 'class']]]
    ],
    'text-anchor': 'top',
    'text-field': [
      'concat',
      ['get', 'name:latin'],
      '\n',
      ['get', 'name:nonlatin']
    ],
    'text-max-width': 9,
    'text-offset': [0, 0.6],
    'text-padding': 2,
    'text-size': 12
  },
  'paint': {
    'text-color': '#666',
    'text-halo-blur': 0.5,
    'text-halo-color': '#ffffff',
    'text-halo-width': 1
  }
};

const rank2Class = ['waste_basket', 'information', 'vending_machine', 'bench', 'photo_booth', 'ticket_validator'];

const layers = [

  // Indoor routing - Below current level \\

  {
    'id': 'indoor-routing-path-outline-below',
    'source': 'indoor-routing-path',
    'type': 'line',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        'all',
        ['<', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['<', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#555555',
      'line-width': 7,
    },
  },
  {
    'id': 'indoor-routing-path-below',
    'source': 'indoor-routing-path',
    'type': 'line',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        'all',
        ['<', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['<', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#aaaaaa',
      'line-width': 5,
    },
  },

  // Indoor areas \\

  {
    'id': 'indoor-polygon',
    'source': 'indoor-vector-tiles',
    'type': 'fill',
    'source-layer': 'area',
    'filter': [
      'all',
      // indoor level matching - start \\
      [
        'let', 'level', 0, [
          // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
          'any',
          ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
          ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
        ]
      ],
      // indoor level matching - end \\
      ['==', ['geometry-type'], 'Polygon'],
      ['!=', ['get', 'class'], 'level']
    ],
    'paint': {
      'fill-color': [
        'case',
        [
          'all',
          ['has', 'access'],
          ['in', ['get', 'access'], ['literal', ['no', 'private']]]
        ],
        '#F2F1F0',
        [
          'any',
          [
            'all',
            ['==', ['get', 'is_poi'], true],
            ['!=', ['get', 'class'], 'corridor']
          ],
          [
            'in',
            ['get', 'subclass'],
            [
              'literal',
              [
                'class',
                'laboratory',
                'office',
                'auditorium',
                'amphitheatre',
                'reception'
              ]
            ]
          ]
        ],
        '#D4EDFF',
        ['==', ['get', 'class'], 'room'],
        '#f0e8f8',
        '#fdfcfa'
      ]
    }
  },
  {
    'id': 'indoor-area',
    'source': 'indoor-vector-tiles',
    'type': 'line',
    'source-layer': 'area',
    'filter': [
      'all',
      // indoor level matching - start \\
      [
        'let', 'level', 0, [
          // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
          'any',
          ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
          ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
        ]
      ],
      // indoor level matching - end \\
      [
        'match',
        ['get', 'class'],
        ['area', 'corridor', 'platform'],
        true,
        false
      ],
    ],
    'paint': {
      'line-color': '#bfbfbf',
      'line-width': 1,
    }
  },
  {
    'id': 'indoor-column',
    'source': 'indoor-vector-tiles',
    'type': 'fill',
    'source-layer': 'area',
    'filter': [
      'all',
      // indoor level matching - start \\
      [
        'let', 'level', 0, [
          // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
          'any',
          ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
          ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
        ]
      ],
      // indoor level matching - end \\

      ['==', ['get', 'class'], 'column']
    ],
    'paint': {
      'fill-color': '#bfbfbf'
    }
  },
  {
    'id': 'indoor-lines',
    'source': 'indoor-vector-tiles',
    'type': 'line',
    'source-layer': 'area',
    'filter': [
      'all',
      // indoor level matching - start \\
      [
        'let', 'level', 0, [
          // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
          'any',
          ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
          ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
        ]
      ],
      // indoor level matching - end \\
      ['match', ['get', 'class'], ['room', 'wall'], true, false]
    ],
    'paint': {
      'line-color': '#bfbfbf',
      'line-width': 1,
    },
  },
  {
    'id': 'indoor-transportation',
    'source': 'indoor-vector-tiles',
    'type': 'line',
    'source-layer': 'transportation',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
        'any',
        ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'paint': {
      'line-color': 'gray',
      'line-dasharray': [0.4, 0.75],
      'line-width': [
        'interpolate',
        ['exponential', 1.4],
        ['zoom'],
        17,
        2,
        20,
        10,
      ],
    }
  },

  // Indoor routing - Current level \\

  {
    'id': 'indoor-routing-path-outline-current',
    'source': 'indoor-routing-path',
    'type': 'line',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
        'any',
        ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#0077c2',
      'line-width': 7,
    },
  },
  {
    'id': 'indoor-routing-path-current',
    'source': 'indoor-routing-path',
    'type': 'line',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
        'any',
        ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#42a5f5',
      'line-width': 5,
    },
  },

  // Indoor routing - Above current level \\

  {
    'id': 'indoor-routing-path-outline-above',
    'source': 'indoor-routing-path',
    'type': 'line',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        'all',
        ['>', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['>', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#555555',
      'line-width': 7,
    },
  },
  {
    'id': 'indoor-routing-path-above',
    'source': 'indoor-routing-path',
    'type': 'line',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        'all',
        ['>', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['>', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#aaaaaa',
      'line-width': 5,
    },
  },

  // Indoor location indicator \\

  {
    'id': 'indoor-position-shadow',
    'source': 'indoor-position',
    'type': 'circle',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
        'any',
        ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'paint': {
      'circle-radius': 17,
      'circle-opacity': 0.7,
      'circle-color': '#000',
      'circle-blur': 1,
      'circle-pitch-alignment': 'map',
    },
  },
  {
    'id': 'indoor-position',
    'source': 'indoor-position',
    'type': 'circle',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
        'any',
        ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'paint': {
      'circle-radius': 8,
      'circle-color': '#42a5f5',
      'circle-stroke-width': 4,
      'circle-stroke-color': '#fff',
      'circle-pitch-alignment': 'map',
    },
  },

  // POIs and labels \\

  {
    'id': 'indoor-transportation-poi',
    'source': 'indoor-vector-tiles',
    'type': 'symbol',
    'source-layer': 'transportation',
    'filter': [
      'all',
      // indoor level matching - start \\
      [
        'let', 'level', 0, [
          // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
          'any',
          ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
          ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
        ]
      ],
      // indoor level matching - end \\

      ['match', ['geometry-type'], ['LineString', 'Point'], true, false],
      [
        'match',
        ['get', 'class'],
        ['elevator', 'escalator', 'steps'],
        true,
        false
      ]
    ],
    'layout': {
      'icon-image': [
        'case',
        ['has', 'conveying'],
        'indoorequal-escalator',
        ['concat', ['literal', 'indoorequal-'], ['get', 'class']]
      ],
      'symbol-placement': 'line-center',
      'icon-rotation-alignment': 'viewport'
    }
  },
  {
    'id': 'indoor-poi-rank1',
    'source': 'indoor-vector-tiles',
    ...commonPoi,
    'filter': [
      'all',
      // indoor level matching - start \\
      [
        'let', 'level', 0, [
          // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
          'any',
          ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
          ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
        ]
      ],
      // indoor level matching - end \\

      ['==', ['geometry-type'], 'Point'],
      [
        'match',
        ['get', 'class'],
        rank2Class,
        false,
        true
      ]
    ]
  },
  {
    'id': 'indoor-poi-rank2',
    'source': 'indoor-vector-tiles',
    ...commonPoi,
    'minzoom': 19,
    'filter': [
      'all',
      // indoor level matching - start \\
      [
        'let', 'level', 0, [
          // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
          'any',
          ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
          ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
        ]
      ],
      // indoor level matching - end \\

      ['==', ['geometry-type'], 'Point'],
      [
        'match',
        ['get', 'class'],
        rank2Class,
        true,
        false
      ]
    ],
  },
  {
    'id': 'indoor-name',
    'source': 'indoor-vector-tiles',
    'type': 'symbol',
    'source-layer': 'area_name',
    'filter': [
      // indoor level matching - start \\
      'let', 'level', 0, [
        // show features with level 0.5; 0.3; 0.7 on level 0 and on level 1
        'any',
        ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
        ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
      ]
      // indoor level matching - end \\
    ],
    'layout': {
      'text-field': [
        'concat',
        ['coalesce', ['get', 'name:latin'], ['get', 'ref']],
        '\n',
        ['get', 'name:nonlatin']
      ],
      'text-max-width': 5,
      'text-size': 14
    },
    'paint': {
      'text-color': '#666',
      'text-halo-color': '#ffffff',
      'text-halo-width': 1
    }
  }
];

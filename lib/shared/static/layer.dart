const commonPoi = {
  'type': 'symbol',
  'source-layer': 'poi',
  'layout': {
    'icon-image': [
      'coalesce',
      [
        'image',
        [
          'concat',
          [
            'literal',
            'indoorequal-'
          ],
          [
            'get',
            'subclass'
          ]
        ],
      ],
      [
        'image',
        [
          'concat',
          [
            'literal',
            'indoorequal-'
          ],
          [
            'get',
            'class'
          ]
        ]
      ]
    ],
    'text-anchor': 'top',
    'text-field': [
      'concat',
      ['get', 'name:latin'],
      '\n',
      ['get', 'name:nonlatin'],
    ],
    'text-max-width': 9,
    'text-offset': [
      0,
      0.6
    ],
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

    // Indoor areas \\

  {
    'id': 'indoor-polygon',
    'source': 'indoor-vector-tiles',
    'type': 'fill',
    'source-layer': 'area',
    'filter': [
      'all',
      [
        '==',
        r'$type',
        'Polygon'
      ],
      [
        '!=',
        'class',
        'level'
      ]
    ],
    'paint': {
      'fill-color': [
        'case',
        // if private
        ['all', ['has', 'access'], ['in', ['get', 'access'], ['literal', ['no', 'private']]]],
        '#F2F1F0',
        // if POI
        ['any',
         ['all', ['==', ['get', 'is_poi'], true], ['!=', ['get', 'class'], 'corridor']],
         [
           'in',
           ['get', 'subclass'],
           ['literal', ['class', 'laboratory', 'office', 'auditorium', 'amphitheatre', 'reception']]]
        ],
        '#D4EDFF',
        // if is a room
        ['==', ['get', 'class'], 'room'],
        '#f0e8f8',
        // default
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
      [
        'in',
        'class',
        'area',
        'corridor',
        'platform'
      ]
    ],
    'paint': {
      'line-color': '#bfbfbf',
      'line-width': 1
    }
  },
  {
    'id': 'indoor-column',
    'source': 'indoor-vector-tiles',
    'type': 'fill',
    'source-layer': 'area',
    'filter': [
      'all',
      [
        '==',
        'class',
        'column'
      ]
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
      [
        'in',
        'class',
        'room',
        'wall'
      ]
    ],
    'paint': {
      'line-color': '#bfbfbf',
      'line-width': 1
    }
  },
  {
    'id': 'indoor-transportation',
    'source': 'indoor-vector-tiles',
    'type': 'line',
    'source-layer': 'transportation',
    'filter': [
      'all'
    ],
    'paint': {
      'line-color': 'gray',
      'line-dasharray': [
        0.4,
        0.75
      ],
      'line-width': {
        'base': 1.4,
        'stops': [
          [
            17,
            2
          ],
          [
            20,
            10
          ]
        ]
      }
    }
  },

  // Indoor routing \\

  {
    'id': 'indoor-routing-path2',
    'source': 'indoor-routing-path',
    'type': 'line',
    'filter': [
      'all',
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
  {
    'id': 'indoor-routing-path',
    'source': 'indoor-routing-path',
    'type': 'line',
    'filter': [
      'all',
    ],
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
      'line-gap-width': 5
    },
    'paint': {
      'line-color': '#0077c2',
      'line-width': 2,
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
      [
        'in',
        r'$type',
        'Point',
        'LineString'
      ],
      [
        'in',
        'class',
        'steps',
        'elevator',
        'escalator'
      ]
    ],
    'layout': {
      'icon-image': [
        'case',
        [
          'has',
          'conveying'
        ],
        'indoorequal-escalator',
        [
          'concat',
          [
            'literal',
            'indoorequal-'
          ],
          [
            'get',
            'class'
          ]
        ]
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
      [
        '==',
        r'$type',
        'Point'
      ],
      [
        '!in',
        'class',
        ...rank2Class
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
      [
        '==',
        r'$type',
        'Point'
      ],
      [
        'in',
        'class',
        ...rank2Class
      ]
    ]
  },
  {
    'id': 'indoor-name',
    'source': 'indoor-vector-tiles',
    'type': 'symbol',
    'source-layer': 'area_name',
    'filter': [
      'all'
    ],
    'layout': {
      'text-field': [
        'concat',
        ['coalesce',
         ['get', 'name:latin'],
         ['get', 'ref'],
        ],
        '\n',
        ['get', 'name:nonlatin'],
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

// When editing these layers, styles and filters always use the new expression syntax
// more info here https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/
// not the old one: https://docs.mapbox.com/mapbox-gl-js/style-spec/other/#other-filter
// Otherwise if errors like 'Invalid filter value: filter property must be a string' may occur
// when both syntaxes are mixed.

const layers = [

  // Underground backdrop layer \\

  {
    'id': 'indoor-tint-layer',
    'source': 'indoor-tint-layer',
    'type': 'fill',
    'filter': [
      'let', 'level', 0, [
        '<', ['var', 'level'], 0
      ],
    ],
    'paint': {
      'fill-color': '#bfbfbf',
    }
  },

  // Underground areas \\

  ..._undergroundIndoorAreas,

  // Indoor routing - Below current level \\

  {
    'id': 'indoor-routing-path-below-outline',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isLowerLevelConnectionFilter,
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#555555',
      'line-width': _routingPathOutlineWidth,
    },
  },
  {
    'id': 'indoor-routing-path-below',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isLowerLevelConnectionFilter,
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#aaaaaa',
      'line-width': _routingPathWidth,
    },
  },

  // Indoor areas \\

  ..._indoorAreas,

  ..._indoorStairs,

  // Indoor routing - Outline - Current level \\

  {
    'id': 'indoor-routing-path-current-outline',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isCurrentLevelConnectionFilter,
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': _routingPathOutlineColor,
      'line-width': _routingPathOutlineWidth,
    },
  },

  // Indoor routing - Lower level connecting path segments \\

  {
    'id': 'indoor-routing-lower-path-down-outline',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isLowerLevelConnectionDownFilter,
    'layout': {
      'line-join': 'round',
    },
    'paint': {
      'line-width': _routingPathOutlineWidth,
      'line-gradient': [
        'interpolate',
        ['linear'],
        ['line-progress'],
        0,
        _routingPathOutlineColor,
        1,
        '#555555',
      ]
    },
  },
  {
    'id': 'indoor-routing-lower-path-down',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isLowerLevelConnectionDownFilter,
    'layout': {
      'line-join': 'round',
    },
    'paint': {
      'line-width': _routingPathWidth,
      'line-gradient': [
        'interpolate',
        ['linear'],
        ['line-progress'],
        0,
        _routingPathFillColor,
        1,
        '#aaaaaa',
      ]
    },
  },
  {
    'id': 'indoor-routing-lower-path-up-outline',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isLowerLevelConnectionUpFilter,
    'layout': {
      'line-join': 'round',
    },
    'paint': {
      'line-width': _routingPathOutlineWidth,
      'line-gradient': [
        'interpolate',
        ['linear'],
        ['line-progress'],
        0,
        '#555555',
        1,
        _routingPathOutlineColor,
      ]
    },
  },
  {
    'id': 'indoor-routing-lower-path-up',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isLowerLevelConnectionUpFilter,
    'layout': {
      'line-join': 'round',
    },
    'paint': {
      'line-width': _routingPathWidth,
      'line-gradient': [
        'interpolate',
        ['linear'],
        ['line-progress'],
        0,
        '#aaaaaa',
        1,
        _routingPathFillColor,
      ]
    },
  },

  // Indoor routing - Outline - Upper level connecting path segments \\

  {
    'id': 'indoor-routing-upper-path-down-outline',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isUpperLevelConnectionDownFilter,
    'layout': {
      'line-join': 'round',
    },
    'paint': {
      'line-width': _routingPathOutlineWidth,
      // 'line-gradient' must be specified using an expression
      // with the special 'line-progress' property
      // the source must have the 'lineMetrics' option set to true
      // note the line points have to be ordered so it fits (the direction of the line)
      // because no other expression are supported here
      'line-gradient': [
        'interpolate',
        ['linear'],
        ['line-progress'],
        0,
        '#555555',
        1,
        _routingPathOutlineColor,
      ]
    },
  },
  {
    'id': 'indoor-routing-upper-path-up-outline',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isUpperLevelConnectionUpFilter,
    'layout': {
      'line-join': 'round',
    },
    'paint': {
      'line-width': _routingPathOutlineWidth,
      'line-gradient': [
        'interpolate',
        ['linear'],
        ['line-progress'],
        0,
        _routingPathOutlineColor,
        1,
        '#555555',
      ]
    },
  },

  // Indoor routing - Concealed edges outline - Below current level \\

  {
    'id': 'indoor-routing-path-concealed-below-outline',
    // required, otherwise line-dasharray will scale with metrics
    'source': 'indoor-routing-path_nometrics',
    'type': 'line',
    'filter': _isLowerLevelConnectionFilter,
    'layout': {
      'line-join': 'round',
    },
    'paint': {
      'line-color': '#555555',
      'line-width': 1,
      'line-gap-width': 5,
      'line-dasharray': ['literal', [4, 4]],
    },
  },

  // Indoor routing - Outline - Above current level \\

  {
    'id': 'indoor-routing-path-above-outline',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isUpperLevelConnectionFilter,
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#555555',
      'line-width': _routingPathOutlineWidth,
    },
  },

  // Indoor routing - Fill - Current level \\

  {
    'id': 'indoor-routing-path-current',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isCurrentLevelConnectionFilter,
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': _routingPathFillColor,
      'line-width': _routingPathWidth,
    },
  },

  // Indoor routing - Fill - Upper level connecting path segments \\

  {
    'id': 'indoor-routing-upper-path-down',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isUpperLevelConnectionDownFilter,
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-width': _routingPathWidth,
      'line-gradient': [
        'interpolate',
        ['linear'],
        ['line-progress'],
        0,
        '#aaaaaa',
        1,
        _routingPathFillColor,
      ]
    },
  },
  {
    'id': 'indoor-routing-upper-path-up',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isUpperLevelConnectionUpFilter,
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-width': _routingPathWidth,
      'line-gradient': [
        'interpolate',
        ['linear'],
        ['line-progress'],
        0,
        _routingPathFillColor,
        1,
        '#aaaaaa',
      ]
    },
  },

  // Indoor routing - Fill - Above current level \\

  {
    'id': 'indoor-routing-path-above',
    'source': 'indoor-routing-path_metrics',
    'type': 'line',
    'filter': _isUpperLevelConnectionFilter,
    'layout': {
      'line-join': 'round',
      'line-cap': 'round',
    },
    'paint': {
      'line-color': '#aaaaaa',
      'line-width': _routingPathWidth,
    },
  },

  // Indoor location indicator \\

  ..._indoorPosition,

  // POIs and labels \\

  ..._pois,

  // Routing POIs \\

  ..._routingPois,
];


/***********
** STYLES **
************/

/// Routing path line color.
const _routingPathFillColor = '#42a5f5';
/// Routing path line outline color.
const _routingPathOutlineColor = '#0077c2';
/// Routing path line color.
const _routingPathWidth = 5;
/// Routing path line color.
const _routingPathOutlineWidth = _routingPathWidth + 2;


/***********
** FILTER **
************/


/// Filter to only show element if level matches current level.
///
/// This will show features with level 0.5; 0.3; 0.7 on level 0 and on level 1

const _isCurrentLevelFilter = [
  'let', 'level', 0, [
    'any',
    ['==', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
    ['==', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
  ],
];

/// Filter to match **any** level below the current level.

const _isLowerLevelFilter = [
  'let', 'level', 0, [
    // important that ceil and floor need to be lower
    'all',
    ['<', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
    ['<', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
  ],
];

/// Filter to match **any** level above the current level.

const _isUpperLevelFilter = [
  'let', 'level', 0, [
    'all',
    ['>', ['ceil', ['to-number', ['get', 'level']]], ['var', 'level']],
    ['>', ['floor', ['to-number', ['get', 'level']]], ['var', 'level']],
  ],
];

/// Filter to match path connections on the current level.

const _isCurrentLevelConnectionFilter = ['all',
  ['==', ['geometry-type'], 'LineString'],
  ['==', ['get', 'connection'], 'level'],
  _isCurrentLevelFilter,
];

/// Filter to match path connections on any lower level that do not connect to current level.

const _isLowerLevelConnectionFilter = ['all',
  ['==', ['geometry-type'], 'LineString'],
  _isLowerLevelFilter,
  ['!', _isLowerLevelConnectionUpFilter],
  ['!', _isLowerLevelConnectionDownFilter],
];

/// Filter to match path connections on any upper level that do not connect to current level.

const _isUpperLevelConnectionFilter = ['all',
  ['==', ['geometry-type'], 'LineString'],
  _isUpperLevelFilter,
  ['!', _isUpperLevelConnectionUpFilter],
  ['!', _isUpperLevelConnectionDownFilter],
];

/// Filter to match paths that act as a connection from the current level to the upper
/// level in upwards directions.

const _isUpperLevelConnectionUpFilter = ['all',
  ['==', ['geometry-type'], 'LineString'],
  ['==', ['get', 'connection'], 'up'],
  // level connecting ways only have their lower level
  _isCurrentLevelFilter,
];

/// Filter to match paths that act as a connection from the current level to the upper
/// level in downwards directions.

const _isUpperLevelConnectionDownFilter = ['all',
  ['==', ['geometry-type'], 'LineString'],
  ['==', ['get', 'connection'], 'down'],
  // level connecting ways only have their lower level
  _isCurrentLevelFilter,
];

/// Filter to match paths that act as a connection from the current level to the lower
/// level in upwards directions.

const _isLowerLevelConnectionUpFilter = ['all',
  ['==', ['geometry-type'], 'LineString'],
  ['==', ['get', 'connection'], 'up'],
  [
    'let', 'level', 0, [
      // level connecting ways only have their lower level
      '==', ['floor', ['to-number', ['get', 'level']]], ['-', ['var', 'level'], 1],
    ]
  ],
];

/// Filter to match paths that act as a connection from the current level to the lower
/// level in downwards directions.

const _isLowerLevelConnectionDownFilter = ['all',
  ['==', ['geometry-type'], 'LineString'],
  ['==', ['get', 'connection'], 'down'],
  [
    'let', 'level', 0, [
      // level connecting ways only have their lower level
      '==', ['floor', ['to-number', ['get', 'level']]], ['-', ['var', 'level'], 1],
    ]
  ],
];


/*****************
** LAYER STYLES **
******************/

/// Indoor location indicator

const _indoorPosition = [
  {
    'id': 'indoor-position-shadow',
    'source': 'indoor-position',
    'type': 'circle',
    'filter': _isCurrentLevelFilter,
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
    'filter': _isCurrentLevelFilter,
    'paint': {
      'circle-radius': 8,
      'circle-color': _routingPathFillColor,
      'circle-stroke-width': 4,
      'circle-stroke-color': '#fff',
      'circle-pitch-alignment': 'map',
    },
  },
];


/// All routing POIs

const _routingPois = [
  {
    'id': 'routing-poi-entrance',
    'source': 'indoor-routing-path_metrics',
    'type': 'symbol',
    'filter': ['all',
      ['==', ['get', 'type'], 'entrance'],
    ],
    'layout': {
      'icon-image': 'door',
      'icon-rotation-alignment': 'viewport',
    },
  },
  {
    'id': 'routing-poi-elevator',
    'source': 'indoor-routing-path_metrics',
    'type': 'symbol',
    'filter': ['all',
      ['==', ['get', 'type'], 'elevator'],
    ],
    'layout': {
      'icon-image': 'elevator',
      'icon-rotation-alignment': 'viewport',
    },
  },
];


/// All indoor areas on the current level.

const _indoorAreas = [
  {
    'id': 'indoor-polygon',
    'source': 'indoor-vector-tiles',
    'type': 'fill',
    'source-layer': 'area',
    'filter': [
      'all',
      _isCurrentLevelFilter,
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
      _isCurrentLevelFilter,
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
      _isCurrentLevelFilter,
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
      _isCurrentLevelFilter,
      ['match', ['get', 'class'], ['room', 'wall'], true, false]
    ],
    'paint': {
      'line-color': '#bfbfbf',
      'line-width': 1,
    },
  },
];

/// Indoor stairs rendering.

const _indoorStairs = [
  {
    'id': 'indoor-stairs-ground',
    'source': 'indoor-vector-tiles',
    'type': 'line',
    'source-layer': 'transportation',
    'filter': _isCurrentLevelFilter,
    'paint': {
      'line-color': '#dddddd',
      'line-width': [
        'interpolate',
        ['exponential', 2],
        ['zoom'],
        10, ['*', 4, ['^', 2, -6]],
        24, ['*', 4, ['^', 2, 8]]
      ],
    }
  },
  {
    'id': 'indoor-stairs-steps',
    'source': 'indoor-vector-tiles',
    'type': 'line',
    'source-layer': 'transportation',
    'filter': _isCurrentLevelFilter,
    'paint': {
      'line-color': '#bfbfbf',
      'line-dasharray': ['literal', [0.01, 0.10]],
      'line-width': [
        'interpolate',
        ['exponential', 2],
        ['zoom'],
        // could in theory take the stairs width property into account if present
        // this is however probably not stored in the indoor maptiles yet
        // see https://gis.stackexchange.com/a/389961 for line scaling
        10, ['*', 4, ['^', 2, -6]],
        24, ['*', 4, ['^', 2, 8]]
      ],
    }
  },
  {
    'id': 'indoor-stairs-rail',
    'source': 'indoor-vector-tiles',
    'type': 'line',
    'source-layer': 'transportation',
    'filter': _isCurrentLevelFilter,
    'paint': {
      'line-color': '#808080',
      'line-width': [
        'interpolate',
        ['exponential', 2],
        ['zoom'],
        10, ['*', 0.25, ['^', 2, -6]],
        24, ['*', 0.25, ['^', 2, 8]]
      ],
      'line-gap-width': [
        'interpolate',
        ['exponential', 2],
        ['zoom'],
        10, ['*', 4, ['^', 2, -6]],
        24, ['*', 4, ['^', 2, 8]]
      ],
    }
  },
];

/// All indoor areas below the current level.

const _undergroundIndoorAreas = [
  {
    'id': 'indoor-polygon-other',
    'source': 'indoor-vector-tiles',
    'type': 'fill',
    'source-layer': 'area',
    'filter': [
      'all',
      _isLowerLevelFilter,
      // indoor level matching - end \\
      ['==', ['geometry-type'], 'Polygon'],
      ['!=', ['get', 'class'], 'level']
    ],
    'paint': {
      'fill-color': '#dddddd',
    },
  },
  {
    'id': 'indoor-area-other',
    'source': 'indoor-vector-tiles',
    'type': 'line',
    'source-layer': 'area',
    'filter': [
      'all',
      _isLowerLevelFilter,
      // indoor level matching - end \\
      [
        'match',
        ['get', 'class'],
        ['area', 'corridor', 'platform'],
        true,
        false
      ]
    ],
    'paint': {
      'line-color': '#bfbfbf',
      'line-width': 1,
    },
  }
];

/// All points of interest of the current level.

const _pois = [
  {
    'id': 'indoor-transportation-poi',
    'source': 'indoor-vector-tiles',
    'type': 'symbol',
    'source-layer': 'transportation',
    'filter': [
      'all',
      _isCurrentLevelFilter,

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
    ..._commonPoi,
    'filter': [
      'all',
      _isCurrentLevelFilter,

      ['==', ['geometry-type'], 'Point'],
      [
        'match',
        ['get', 'class'],
        _rank2Class,
        false,
        true
      ]
    ]
  },
  {
    'id': 'indoor-poi-rank2',
    'source': 'indoor-vector-tiles',
    ..._commonPoi,
    'minzoom': 19.0,
    'filter': [
      'all',
      _isCurrentLevelFilter,

      ['==', ['geometry-type'], 'Point'],
      [
        'match',
        ['get', 'class'],
        _rank2Class,
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
    'filter': _isCurrentLevelFilter,
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
  },
];

const _commonPoi = {
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
    'text-offset': ['literal', [0, 0.6]],
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

const _rank2Class = ['waste_basket', 'information', 'vending_machine', 'bench', 'photo_booth', 'ticket_validator'];


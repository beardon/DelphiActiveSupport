unit Inflectors;

interface

const
  INFLECTOR_PLURALS: array[0..20, 0..1] of string =
    (('(.*)$', '$1s'),
    ('(.*)s$', '$1s'),
    ('(ax|test)is$', '$1es'),
    ('(octop|vir)us$', '$1i'),
    ('(octop|vir)i$', '$1i'),
    ('(alias|status)$', '$1es'),
    ('(bu)s$', '$1ses'),
    ('(buffal|tomat)o$', '$1oes'),
    ('([ti])um$', '$1a'),
    ('([ti])a$', '$1a'),
    ('sis$', 'ses'),
    ('(?:([^f])fe|([lr])f)$', '$1\2ves'),
    ('(hive)$', '$1s'),
    ('([^aeiouy]|qu)y$', '$1ies'),
    ('(x|ch|ss|sh)$', '$1es'),
    ('(matr|vert|ind)(?:ix|ex)$', '$1ices'),
    ('([m|l])ouse$', '$1ice'),
    ('([m|l])ice$', '$1ice'),
    ('^(ox)$', '$1en'),
    ('^(oxen)$', '$1'),
    ('(quiz)$', '$1zes'));

  INFLECTOR_SINGULARS: array[0..26, 0..1] of string =
    (('(.*)s$', '$1'),
    ('(ss)$', '$1'),
    ('(n)ews$', '$1ews'),
    ('([ti])a$', '$1um'),
    ('((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)$', '$1sis'),
    ('(^analy)(sis|ses)$', '$1sis'),
    ('([^f])ves$', '$1fe'),
    ('(hive)s$', '$1'),
    ('(tive)s$', '$1'),
    ('([lr])ves$', '$1f'),
    ('([^aeiouy]|qu)ies$', '$1y'),
    ('(s)eries$', '$1eries'),
    ('(m)ovies$', '$1ovie'),
    ('(x|ch|ss|sh)es$', '$1'),
    ('^(m|l)ice$', '$1ouse'),
    ('(bus)(es)?$', '$1'),
    ('(o)es$', '$1'),
    ('(shoe)s$', '$1'),
    ('(cris|test)(is|es)$', '$1is'),
    ('^(a)x[ie]s$', '$1xis'),
    ('(octop|vir)(us|i)$', '$1us'),
    ('(alias|status)(es)?$', '$1'),
    ('^(ox)en', '$1'),
    ('(vert|ind)ices$', '$1ex'),
    ('(matr)ices$', '$1ix'),
    ('(quiz)zes$', '$1'),
    ('(database)s$', '$1'));

  INFLECTOR_IRREGULARS: array[0..6, 0..1] of string =
    (('person', 'people'),
    ('man', 'men'),
    ('child', 'children'),
    ('sex', 'sexes'),
    ('move', 'moves'),
    ('cow', 'kine'),
    ('zombie', 'zombies'));

  INFLECTOR_UNCOUNTABLE: array[0..9] of string =
    ('equipment', 'information', 'rice', 'money', 'species', 'series', 'fish', 'sheep', 'jeans', 'miscellaneous');

implementation

end.

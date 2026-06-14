// lib/features/workout/models/exercise_model.dart

class ExerciseConfig {
  final String  name;
  final bool    primary;
  final String  warmupSets; // e.g. "1~2"
  final int     sets;
  final String  reps;       // e.g. "6~8"
  final String  rest;       // e.g. "3~5"
  final String  muscle;
  final String  alt1;
  final String  alt2;
  final String  note;
  final String? videoUrl;

  const ExerciseConfig({
    required this.name,
    required this.primary,
    required this.warmupSets,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.muscle,
    this.alt1    = '',
    this.alt2    = '',
    this.note    = '',
    this.videoUrl,
  });

  factory ExerciseConfig.fromJson(Map<String, dynamic> j) => ExerciseConfig(
    name:        j['name']?.toString()    ?? '',
    primary:     j['primary']  == true,
    warmupSets:  j['wu']?.toString()      ?? '0',
    sets:        (j['sets'] as num?)?.toInt() ?? 1,
    reps:        j['reps']?.toString()    ?? '8~12',
    rest:        j['rest']?.toString()    ?? '2~3',
    muscle:      j['muscle']?.toString()  ?? '',
    alt1:        j['alt1']?.toString()    ?? '',
    alt2:        j['alt2']?.toString()    ?? '',
    note:        j['note']?.toString()    ?? '',
    videoUrl:    j['videoUrl']?.toString(),
  );
}

/// Static exercise database — mirrors config.js EXERCISES
class ExerciseDB {
  ExerciseDB._();

  static const Map<String, List<Map<String, dynamic>>> _rawData = {
    // ─── Upper / Lower ───────────────────────────────────
    'Upper A': [
      {'name':'Smith High Incline Press',        'primary':true, 'wu':'1~2','sets':2,'reps':'6~8', 'rest':'3~5','muscle':'صدر عالي',   'alt1':'DB High Incline Press',       'note':'ضم ايدك لجوه عشان تحاكي اتجاه الياف الصدر العالي'},
      {'name':'Machine Wide Grip Lat Pulldown',  'primary':true, 'wu':'1~3','sets':2,'reps':'6~8', 'rest':'3~5','muscle':'لاتس',       'alt1':'Cable Wide Grip Lat',          'note':'ركز في مسار كوعك وانك بتضم كتافك'},
      {'name':'Chest Press Machine',             'primary':false,'wu':'1~2','sets':2,'reps':'6~10','rest':'3~5','muscle':'صدر مستوي',  'alt1':'DB Flat Press',                'note':''},
      {'name':'T Bar Row',                       'primary':true, 'wu':'1~2','sets':2,'reps':'5~7', 'rest':'3~5','muscle':'ظهر علوي',  'alt1':'Incline DB Row','alt2':'Cable Row','note':'افتح كيعانك لبره حاول تقرب من زاوية 90'},
      {'name':'SA Tricep Pushdown',              'primary':false,'wu':'0',  'sets':2,'reps':'6~10','rest':'2~3','muscle':'ترايسبس',   'alt1':'Double Rope Pushdown',         'note':''},
      {'name':'DB Preacher Curl',                'primary':true, 'wu':'0',  'sets':2,'reps':'6~10','rest':'2~3','muscle':'بايسبس',    'alt1':'Face Away Curl','alt2':'DB Curls','note':'بلاش مدى حركي زياده من الكتف'},
      {'name':'Reverse Grip Curls',              'primary':false,'wu':'0',  'sets':2,'reps':'6~10','rest':'2~3','muscle':'ساعد أمامي','alt1':'DB Reverse Curl',              'note':''},
    ],
    'Lower A': [
      {'name':'Machine Lateral Raises',          'primary':true, 'wu':'1~2','sets':2,'reps':'6~8', 'rest':'2~3','muscle':'كتف جانبي','alt1':'Cable Lateral Raises','alt2':'DB Lateral Raises','note':''},
      {'name':'Leg Press Calf Raises',           'primary':false,'wu':'1~2','sets':2,'reps':'5~7', 'rest':'1~2','muscle':'سمانة',     'alt1':'Smith Calf Raises',            'note':''},
      {'name':'Hack Squat',                      'primary':true, 'wu':'1~3','sets':1,'reps':'5~8', 'rest':'3~5','muscle':'رجل كوادز','alt1':'Smith Squat','alt2':'Leg Press', 'note':'120 درجه من ثني الركبه'},
      {'name':'SA Rear Delt Flies',              'primary':false,'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'كتف خلفي', 'alt1':'Reverse Pec Dec',              'note':''},
      {'name':'Seated Leg Curl',                 'primary':true, 'wu':'1~2','sets':1,'reps':'8~12','rest':'2~3','muscle':'رجل خلفيه','alt1':'Lying Leg Curl',               'note':''},
      {'name':'Leg Extension',                   'primary':true, 'wu':'1~2','sets':2,'reps':'8~12','rest':'2~3','muscle':'رجل أماميه','alt1':'',                             'note':''},
      {'name':'Hip Adduction',                   'primary':false,'wu':'1~2','sets':2,'reps':'6~8', 'rest':'2~3','muscle':'ضمه',      'alt1':'Cable Hip Adduction',          'note':''},
      {'name':'Wrist Curls',                     'primary':false,'wu':'0',  'sets':3,'reps':'6~10','rest':'1~2','muscle':'ساعد خلفي','alt1':'',                             'note':''},
    ],
    'Upper B': [
      {'name':'Chest Press Machine',             'primary':true, 'wu':'1~2','sets':2,'reps':'6~8', 'rest':'3~5','muscle':'صدر مستوي','alt1':'DB Flat Press','alt2':'Smith Flat Press','note':''},
      {'name':'T Bar Row',                       'primary':true, 'wu':'1~2','sets':2,'reps':'5~7', 'rest':'3~5','muscle':'ظهر علوي','alt1':'Incline DB Row','alt2':'Cable Row','note':''},
      {'name':'Incline Chest Press Machine',     'primary':false,'wu':'1~2','sets':1,'reps':'6~10','rest':'3~5','muscle':'صدر عالي', 'alt1':'DB Incline Press',             'note':''},
      {'name':'SA Lat Row',                      'primary':false,'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'لاتس',     'alt1':'Cable SA Lat Row','alt2':'DB SA Lat Row','note':''},
      {'name':'Face Away Curl',                  'primary':true, 'wu':'0',  'sets':2,'reps':'6~10','rest':'2~3','muscle':'بايسبس',  'alt1':'DB Preacher Curl','alt2':'DB Curls','note':''},
      {'name':'Overhead Extension',              'primary':true, 'wu':'0',  'sets':2,'reps':'6~10','rest':'2~3','muscle':'ترايسبس','alt1':'DB Skull Crusher',              'note':''},
      {'name':'Cable Shrugs',                    'primary':false,'wu':'1',  'sets':2,'reps':'6~8', 'rest':'2~3','muscle':'ترابيس', 'alt1':'Smith Kelso Shrugs',            'note':''},
    ],
    'Lower B': [
      {'name':'Cable Lateral Raises',            'primary':true, 'wu':'1~2','sets':2,'reps':'5~8', 'rest':'2~3','muscle':'كتف جانبي','alt1':'DB Lateral Raises',            'note':''},
      {'name':'SLDL',                            'primary':true, 'wu':'1~3','sets':1,'reps':'5~7', 'rest':'3~5','muscle':'جلوتس',   'alt1':'RDL','alt2':'Hip Extension',     'note':''},
      {'name':'Seated Leg Curl',                 'primary':true, 'wu':'1~2','sets':2,'reps':'8~12','rest':'2~3','muscle':'رجل خلفيه','alt1':'Lying Leg Curl',               'note':''},
      {'name':'Leg Extension',                   'primary':false,'wu':'1~2','sets':1,'reps':'8~12','rest':'2~3','muscle':'رجل أماميه','alt1':'',                            'note':''},
      {'name':'Hip Adduction',                   'primary':false,'wu':'1~2','sets':1,'reps':'6~8', 'rest':'2~3','muscle':'ضمه',     'alt1':'Cable Hip Adduction',          'note':''},
      {'name':'Lat Pulldown Crunches',           'primary':false,'wu':'0',  'sets':1,'reps':'6~10','rest':'1~2','muscle':'بطن',     'alt1':'Cable Crunch',                 'note':''},
      {'name':'Leg Press Calf Raises',           'primary':false,'wu':'1~2','sets':2,'reps':'5~7', 'rest':'1~2','muscle':'سمانة',   'alt1':'Smith Calf Raises',            'note':''},
    ],
    // ─── Anterior / Posterior ─────────────────────────────
    'Anterior A': [
      {'name':'Machine Shoulder Press',          'primary':true, 'wu':'1~2','sets':1,'reps':'6~8', 'rest':'3~5','muscle':'كتف أمامي','alt1':'DB Shoulder Press',            'note':''},
      {'name':'Chest Press Machine',             'primary':true, 'wu':'1~2','sets':3,'reps':'6~10','rest':'3~5','muscle':'صدر مستوي','alt1':'DB Flat Press',                'note':''},
      {'name':'Hack Squat',                      'primary':true, 'wu':'1~3','sets':2,'reps':'5~8', 'rest':'3~5','muscle':'رجل كوادز','alt1':'Smith Squat','alt2':'Leg Press','note':''},
      {'name':'Machine Lateral Raises',          'primary':true, 'wu':'1~2','sets':3,'reps':'6~8', 'rest':'2~3','muscle':'كتف جانبي','alt1':'Cable Lateral Raises',        'note':''},
      {'name':'Overhead Extension',              'primary':true, 'wu':'0',  'sets':2,'reps':'6~10','rest':'2~3','muscle':'ترايسبس','alt1':'DB Skull Crusher',              'note':''},
      {'name':'Butterfly',                       'primary':false,'wu':'1~2','sets':1,'reps':'6~10','rest':'2~3','muscle':'صدر مستوي','alt1':'Cable Fly','alt2':'DB Fly',    'note':''},
      {'name':'Lat Pulldown Crunches',           'primary':false,'wu':'0',  'sets':2,'reps':'6~10','rest':'1~2','muscle':'بطن',     'alt1':'Cable Crunch',                 'note':''},
      {'name':'Leg Extension',                   'primary':false,'wu':'1~2','sets':1,'reps':'8~12','rest':'2~3','muscle':'رجل أماميه','alt1':'',                           'note':''},
    ],
    'Posterior A': [
      {'name':'T Bar Row',                       'primary':true, 'wu':'1~2','sets':2,'reps':'5~7', 'rest':'3~5','muscle':'ظهر علوي','alt1':'Incline DB Row','alt2':'Cable Row','note':''},
      {'name':'Machine Wide Grip Lat Pulldown',  'primary':true, 'wu':'1~3','sets':3,'reps':'6~8', 'rest':'3~5','muscle':'لاتس',    'alt1':'Cable Wide Grip Lat',           'note':''},
      {'name':'RDL',                             'primary':true, 'wu':'1~3','sets':1,'reps':'5~8', 'rest':'3~5','muscle':'جلوتس',   'alt1':'Hip Extension','alt2':'Hip Thrust','note':''},
      {'name':'SA Rear Delt Flies',              'primary':false,'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'كتف خلفي','alt1':'Reverse Pec Dec',              'note':''},
      {'name':'Seated Leg Curl',                 'primary':true, 'wu':'1~2','sets':2,'reps':'8~12','rest':'2~3','muscle':'رجل خلفيه','alt1':'Lying Leg Curl',              'note':''},
      {'name':'Preacher Curl Machine',           'primary':true, 'wu':'0',  'sets':2,'reps':'6~10','rest':'2~3','muscle':'بايسبس', 'alt1':'Face In Curls',                'note':''},
      {'name':'Leg Press Calf Raises',           'primary':false,'wu':'0',  'sets':2,'reps':'5~7', 'rest':'1~2','muscle':'سمانة',  'alt1':'Smith Calf Raises',            'note':''},
      {'name':'Wrist Curls',                     'primary':false,'wu':'0',  'sets':2,'reps':'6~10','rest':'1~2','muscle':'ساعد خلفي','alt1':'Reverse Curl',               'note':''},
    ],
    'Anterior B': [
      {'name':'Incline Chest Press Machine',     'primary':true, 'wu':'1~2','sets':2,'reps':'6~10','rest':'3~5','muscle':'صدر عالي','alt1':'DB Incline Press',             'note':''},
      {'name':'Machine Shoulder Press',          'primary':true, 'wu':'1~2','sets':2,'reps':'6~8', 'rest':'3~5','muscle':'كتف أمامي','alt1':'DB Shoulder Press',           'note':''},
      {'name':'Leg Extension',                   'primary':true, 'wu':'1~2','sets':3,'reps':'8~12','rest':'3~5','muscle':'رجل أماميه','alt1':'',                           'note':''},
      {'name':'Cable Lateral Raises',            'primary':true, 'wu':'1~2','sets':2,'reps':'6~8', 'rest':'2~3','muscle':'كتف جانبي','alt1':'DB Lateral Raises',          'note':''},
      {'name':'SA Tricep Pushdown',              'primary':true, 'wu':'0',  'sets':3,'reps':'6~10','rest':'2~3','muscle':'ترايسبس','alt1':'Double Rope Pushdown',         'note':''},
      {'name':'Butterfly',                       'primary':false,'wu':'1~2','sets':1,'reps':'6~10','rest':'2~3','muscle':'صدر مستوي','alt1':'Cable Fly',                  'note':''},
      {'name':'Hip Adduction',                   'primary':false,'wu':'1~2','sets':1,'reps':'6~8', 'rest':'2~3','muscle':'ضمه',    'alt1':'Cable Hip Adduction',          'note':''},
      {'name':'Reverse Grip Curls',              'primary':false,'wu':'0',  'sets':2,'reps':'6~10','rest':'2~3','muscle':'ساعد أمامي','alt1':'DB Reverse Curl',           'note':''},
    ],
    'Posterior B': [
      {'name':'T Bar Row',                       'primary':true, 'wu':'1~2','sets':2,'reps':'5~7', 'rest':'3~5','muscle':'ظهر علوي','alt1':'Incline DB Row','alt2':'Cable Row','note':''},
      {'name':'SA Lat Row',                      'primary':true, 'wu':'1~3','sets':2,'reps':'6~8', 'rest':'3~5','muscle':'لاتس',   'alt1':'Cable SA Lat Row','alt2':'DB SA Lat Row','note':''},
      {'name':'Face Away Curl',                  'primary':true, 'wu':'0',  'sets':2,'reps':'6~10','rest':'2~3','muscle':'بايسبس','alt1':'DB Curls',                      'note':''},
      {'name':'RDL',                             'primary':true, 'wu':'1~2','sets':1,'reps':'5~8', 'rest':'3~5','muscle':'جلوتس', 'alt1':'Hip Extension','alt2':'Hip Thrust','note':''},
      {'name':'SA Rear Delt Flies',              'primary':false,'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'كتف خلفي','alt1':'Reverse Pec Dec',             'note':''},
      {'name':'Cable Shrugs',                    'primary':false,'wu':'1',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'ترابيس','alt1':'DB Shrugs',                     'note':''},
      {'name':'Seated Leg Curl',                 'primary':true, 'wu':'1~2','sets':2,'reps':'8~12','rest':'2~3','muscle':'رجل خلفيه','alt1':'Lying Leg Curl',             'note':''},
      {'name':'Leg Press Calf Raises',           'primary':false,'wu':'1~2','sets':2,'reps':'5~7', 'rest':'1~2','muscle':'سمانة', 'alt1':'Smith Calf Raises',            'note':''},
    ],
    // ─── Full Body ────────────────────────────────────────
    'Full Body #1': [
      {'name':'Smith High Incline Press',        'primary':true, 'wu':'1~2','sets':1,'reps':'4~6', 'rest':'3~5','muscle':'صدر عالي','alt1':'DB High Incline Press',        'note':''},
      {'name':'T Bar Row',                       'primary':true, 'wu':'1~2','sets':1,'reps':'5~7', 'rest':'3~5','muscle':'ظهر علوي','alt1':'Incline DB Row','alt2':'Cable Row','note':''},
      {'name':'Machine Lateral Raises',          'primary':false,'wu':'0',  'sets':1,'reps':'6~8', 'rest':'2~3','muscle':'كتف جانبي','alt1':'Cable Lateral Raises',       'note':''},
      {'name':'Machine Wide Grip Lat Pulldown',  'primary':true, 'wu':'1~3','sets':1,'reps':'6~8', 'rest':'3~5','muscle':'لاتس',   'alt1':'Cable Wide Grip Lat',          'note':''},
      {'name':'DB Preacher Curl',                'primary':true, 'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'بايسبس','alt1':'Face Away Curl',                'note':''},
      {'name':'SA Tricep Pushdown',              'primary':true, 'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'ترايسبس','alt1':'Double Rope Pushdown',         'note':''},
      {'name':'Seated Leg Curl',                 'primary':true, 'wu':'1~2','sets':1,'reps':'8~12','rest':'2~3','muscle':'رجل خلفيه','alt1':'Lying Leg Curl',             'note':''},
      {'name':'Leg Extension',                   'primary':true, 'wu':'1~2','sets':1,'reps':'8~12','rest':'2~3','muscle':'رجل أماميه','alt1':'',                          'note':''},
      {'name':'Leg Press Calf Raises',           'primary':false,'wu':'1~2','sets':2,'reps':'5~7', 'rest':'1~2','muscle':'سمانة',  'alt1':'Smith Calf Raises',            'note':''},
    ],
    'Full Body #2': [
      {'name':'Hack Squat',                      'primary':true, 'wu':'1~3','sets':1,'reps':'5~8', 'rest':'3~5','muscle':'رجل كوادز','alt1':'Smith Squat','alt2':'Leg Press','note':''},
      {'name':'Seated Leg Curl',                 'primary':true, 'wu':'1~2','sets':1,'reps':'6~10','rest':'2~3','muscle':'رجل خلفيه','alt1':'Lying Leg Curl',             'note':''},
      {'name':'T Bar Row',                       'primary':true, 'wu':'1~2','sets':1,'reps':'5~7', 'rest':'3~5','muscle':'ظهر علوي','alt1':'Incline DB Row','alt2':'Cable Row','note':''},
      {'name':'Chest Press Machine',             'primary':true, 'wu':'1~2','sets':1,'reps':'8~10','rest':'3~5','muscle':'صدر مستوي','alt1':'DB Flat Press',              'note':''},
      {'name':'Machine Shoulder Press',          'primary':true, 'wu':'1',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'كتف أمامي','alt1':'DB Shoulder Press',          'note':''},
      {'name':'DB Preacher Curl',                'primary':true, 'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'بايسبس','alt1':'Face Away Curl',                'note':''},
      {'name':'SA Tricep Pushdown',              'primary':true, 'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'ترايسبس','alt1':'Double Rope Pushdown',         'note':''},
    ],
    'Full Body #3': [
      {'name':'SLDL',                            'primary':true, 'wu':'1~3','sets':1,'reps':'5~7', 'rest':'3~5','muscle':'جلوتس',  'alt1':'RDL','alt2':'Hip Extension',    'note':''},
      {'name':'45D T Bar Row',                   'primary':true, 'wu':'1~2','sets':2,'reps':'5~7', 'rest':'3~5','muscle':'ظهر علوي','alt1':'45D Incline DB Row',          'note':''},
      {'name':'Incline Chest Press Machine',     'primary':true, 'wu':'1~2','sets':2,'reps':'6~8', 'rest':'3~5','muscle':'صدر عالي','alt1':'DB Incline Press',            'note':''},
      {'name':'Leg Extension',                   'primary':true, 'wu':'1~2','sets':2,'reps':'6~10','rest':'2~3','muscle':'رجل أماميه','alt1':'',                          'note':''},
      {'name':'Face Away Curl',                  'primary':true, 'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'بايسبس','alt1':'DB Preacher Curl','alt2':'DB Curls','note':''},
      {'name':'Overhead Extension',              'primary':true, 'wu':'0',  'sets':1,'reps':'6~10','rest':'2~3','muscle':'ترايسبس','alt1':'DB Skull Crusher',             'note':''},
    ],
    // ─── Arnold ───────────────────────────────────────────
    'Chest & Back': [
      {'name':'Incline Chest Press Machine',     'primary':true, 'wu':'1~2','sets':3,'reps':'6~8', 'rest':'3~5','muscle':'صدر عالي','alt1':'DB Incline Press',            'note':''},
      {'name':'Machine Wide Grip Lat Pulldown',  'primary':true, 'wu':'1~3','sets':3,'reps':'6~8', 'rest':'3~5','muscle':'لاتس',   'alt1':'Cable Wide Grip Lat',          'note':''},
      {'name':'Chest Press Machine',             'primary':true, 'wu':'1~2','sets':2,'reps':'6~10','rest':'3~5','muscle':'صدر مستوي','alt1':'DB Flat Press',              'note':''},
      {'name':'T Bar Row',                       'primary':true, 'wu':'1~2','sets':2,'reps':'5~7', 'rest':'3~5','muscle':'ظهر علوي','alt1':'Incline DB Row','alt2':'Cable Row','note':''},
      {'name':'Butterfly',                       'primary':false,'wu':'1~2','sets':2,'reps':'8~12','rest':'2~3','muscle':'صدر مستوي','alt1':'Cable Fly',                  'note':''},
      {'name':'SA Rear Delt Flies',              'primary':false,'wu':'0',  'sets':2,'reps':'8~12','rest':'2~3','muscle':'كتف خلفي','alt1':'Reverse Pec Dec',             'note':''},
    ],
    'Shoulders & Arms': [
      {'name':'Machine Shoulder Press',          'primary':true, 'wu':'1~2','sets':3,'reps':'6~8', 'rest':'3~5','muscle':'كتف أمامي','alt1':'DB Shoulder Press',          'note':''},
      {'name':'Machine Lateral Raises',          'primary':true, 'wu':'1~2','sets':3,'reps':'6~8', 'rest':'2~3','muscle':'كتف جانبي','alt1':'Cable Lateral Raises',       'note':''},
      {'name':'DB Preacher Curl',                'primary':true, 'wu':'0',  'sets':3,'reps':'6~10','rest':'2~3','muscle':'بايسبس','alt1':'Face Away Curl',                'note':''},
      {'name':'Overhead Extension',              'primary':true, 'wu':'0',  'sets':3,'reps':'6~10','rest':'2~3','muscle':'ترايسبس','alt1':'DB Skull Crusher',             'note':''},
      {'name':'Reverse Grip Curls',              'primary':false,'wu':'0',  'sets':2,'reps':'8~12','rest':'2~3','muscle':'ساعد أمامي','alt1':'DB Reverse Curl',           'note':''},
    ],
    // ─── PPL ─────────────────────────────────────────────
    'PUSH': [
      {'name':'Chest Press Machine',             'primary':true, 'wu':'1~2','sets':3,'reps':'6~8', 'rest':'3~5','muscle':'صدر مستوي','alt1':'DB Flat Press',              'note':''},
      {'name':'Machine Shoulder Press',          'primary':true, 'wu':'1~2','sets':3,'reps':'6~8', 'rest':'3~5','muscle':'كتف أمامي','alt1':'DB Shoulder Press',          'note':''},
      {'name':'Machine Lateral Raises',          'primary':true, 'wu':'1~2','sets':3,'reps':'6~8', 'rest':'2~3','muscle':'كتف جانبي','alt1':'Cable Lateral Raises',       'note':''},
      {'name':'Incline Chest Press Machine',     'primary':false,'wu':'1~2','sets':2,'reps':'8~10','rest':'3~5','muscle':'صدر عالي','alt1':'DB Incline Press',            'note':''},
      {'name':'SA Tricep Pushdown',              'primary':true, 'wu':'0',  'sets':3,'reps':'8~12','rest':'2~3','muscle':'ترايسبس','alt1':'Double Rope Pushdown',         'note':''},
      {'name':'Butterfly',                       'primary':false,'wu':'1',  'sets':2,'reps':'10~12','rest':'2~3','muscle':'صدر مستوي','alt1':'Cable Fly',                 'note':''},
    ],
    'PULL': [
      {'name':'Machine Wide Grip Lat Pulldown',  'primary':true, 'wu':'1~3','sets':3,'reps':'6~8', 'rest':'3~5','muscle':'لاتس',   'alt1':'Cable Wide Grip Lat',          'note':''},
      {'name':'T Bar Row',                       'primary':true, 'wu':'1~2','sets':3,'reps':'5~7', 'rest':'3~5','muscle':'ظهر علوي','alt1':'Incline DB Row','alt2':'Cable Row','note':''},
      {'name':'DB Preacher Curl',                'primary':true, 'wu':'0',  'sets':3,'reps':'8~12','rest':'2~3','muscle':'بايسبس','alt1':'Face Away Curl',                'note':''},
      {'name':'SA Rear Delt Flies',              'primary':false,'wu':'0',  'sets':2,'reps':'10~12','rest':'2~3','muscle':'كتف خلفي','alt1':'Reverse Pec Dec',            'note':''},
      {'name':'Cable Shrugs',                    'primary':false,'wu':'1',  'sets':2,'reps':'8~12','rest':'2~3','muscle':'ترابيس','alt1':'DB Shrugs',                     'note':''},
      {'name':'Reverse Grip Curls',              'primary':false,'wu':'0',  'sets':2,'reps':'10~12','rest':'2~3','muscle':'ساعد أمامي','alt1':'DB Reverse Curl',          'note':''},
    ],
  };

  static const List<Map<String, dynamic>> _warmup = [
    {'name':'Pallof Press',      'reps':'10/side','hasWeight':true, 'note':'ثبّت جسمك وحرك ذراعك فقط'},
    {'name':'Pallof Rotation',   'reps':'10/side','hasWeight':true, 'note':'حوضك ثابت'},
    {'name':'External Rotation', 'reps':'10 reps','hasWeight':true, 'note':'من الكتف فقط'},
    {'name':'Scapula Push Plus', 'reps':'10 reps','hasWeight':true, 'note':'من لوح الكتف — وزن خفيف'},
    {'name':'Neck Extension',    'reps':'12 reps','hasWeight':true, 'note':'وزن خفيف جداً — أسفل الرأس'},
    {'name':'Neck Flexion',      'reps':'12 reps','hasWeight':true, 'note':'وزن خفيف — الذقن للصدر'},
  ];

  static List<ExerciseConfig> getSession(String sessionName) {
    final raw = _rawData[sessionName] ?? [];
    return raw.map((j) => ExerciseConfig.fromJson(j)).toList();
  }

  static List<Map<String, dynamic>> get warmup => _warmup;

  static bool hasSession(String name) => _rawData.containsKey(name);
}

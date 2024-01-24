env <- data.table::data.table(
   local = rep(c(
      # Wallacea
      "Flores", "Luzon", "Mindanao",
      "Mindoro", "Negros", "Timor",
      # Macronesia
      "Fuerteventura", "Gran Canaria", "Tenerife",
      # Pacific Isolates
      "Isabela", "Santa Cruz", "Amami",
      "Kume", "Okinawa", "Tokuno",
      "Santa Rosae",
      # Mediterranean
      "Crete", "Cyprus", "Karpathos", "Majorca",
      "Naxos", "Sardinia", "Sicily", "Tilos",
      # Caribbean Islands
      "Anguilla", "Antigua", "Barbados",
      "Bonaire", "Cuba", "Curaçao",
      "Hispaniola", "Jamaica", "Martinique",
      "Puerto Rico", "Saint Kitts", "Saint Lucia",
      "Saint Vincent"), each = 2L),
   period = rep(c("past", "present"), times = 37L),
   year = as.integer(c(
      # Wallacea
      1500, 2023,  1521, 2023,  1500, 2023,
      1570, 2023,  1565, 2023,  1514, 2023,
      # Macronesia
      1340, 2023, 1300, 2023, 1464, 2023,
      # Pacific Isolates
      NA, 2023, NA, 2023, NA, 2023,
      NA, 2023, NA, 2023, NA, 2023,
      NA, 2023,
      # Mediterranean
      NA, 2023, NA, 2023, NA, 2023, NA, 2023,
      NA, 2023, NA, 2023, NA, 2023, NA, 2023,
      # Caribbean Islands
      1631, 2023,  1493, 2023,  1500, 2023,
      1499, 2023,  1492, 2023,  1499, 2023,
      1492, 2023,  1494, 2023,  1502, 2023,
      1493, 2023,  1493, 2023,  1550, 2023,
      1498, 2023)),
   coordinates = rep(c(
      # Wallacea
      "8°40′29″S 121°23′04″E", "16°N 121°E", "8°00′N 125°00′E",
      "12°55′49″N 121°5′40″E", "10°N 123°E", "9°14′S 124°56′E",
      # Macronesia
      "28°24′N 14°00′W", "27°58′N 15°36′W", "28°16′7″N 16°36′20″W",
      # Pacific Isolates
      "00°30′S 91°04′W", "0.623017°S 90.368254°W","28°19′35″N 129°22′29″E",
      "26°20′28″N 126°48′18″E", "26°28′46″N 127°55′40″E", "27°49′12″N 128°55′56″E",
      "34°00′N 120°00′W",
      # Mediterranean
      "35°12.6′N 24°54.6′E", "35°10′N 33°22′E", "35°35′N 27°08′E","39°37′N 2°59′E",
      "37°05′15″N 25°24′14″E","40°00′N 09°00′E","37°30′N 14°00′E","36°26′N 27°22′E",
      # Caribbean Islands
      "18.22723°N 63.04899°W", "17°05′06″N 61°48′00″W", "13°05′52″N 59°37′06″W",
      "12°9′N 68°16′W","23°8′N 82°23′W", "12°7′N 68°56′W",
      "19°N 71°W", "17°58′17″N 76°47′35″W", "14°39′00″N 61°00′54″W",
      "18°27′N 66°6′W", "17.31°N 62.72°W", "13°53′00″N 60°58′00″W",
      "13°15′N 61°12′W"), each = 2),
   alpha_grain = rep(as.integer(c(
      # Wallacea
      15530, 109965, 97530,
      10571, 13309, 30777,
      # Macronesia
      1660,  1560, 2034,
      # Pacific Isolates
      4586, 986, 713,
      59, 1199, 248,
      NA,
      # Mediterranean
      8450, 9250, 325, 3640,
      430, 24090, 25511, 65,
      # Caribbean Islands
      91, 281, 439,
      288, 110860, 444,
      76192, 10991, 1128,
      8887, 174, 617,
      345)), each = 2)
)

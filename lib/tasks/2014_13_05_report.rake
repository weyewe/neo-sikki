

task :open_group_loan_report => :environment do
  rows =  [["352", "Sapi D", "4900000.0", 7, 25], ["412", "DKI 412", "6400000.0", 7, 25], ["350", "Karya", "6000000.0", 7, 25], ["383", "Barong C 383", "7200000.0", 8, 25], ["332", "Lorong", "5600000.0", 7, 20], ["328", "Asrama DKI 328", "6800000.0", 8, 25], ["27", "Jl. B2 RBU A 27", "9000000.0", 8, 25], ["30", "DKI 30", "7700000.0", 9, 25], ["356", "Merdeka D", "14100000.0", 8, 25], ["354", "Merdeka C", "12100000.0", 7, 25], ["51", "Kakap A", "11300000.0", 10, 25], ["362", "Cemara B 362", "6400000.0", 7, 25], ["415", "Mantang 415", "8200000.0", 9, 20], ["397", "Cipucang A 397", "6400000.0", 7, 25], ["288", "Semprotan E 288", "14700000.0", 8, 25], ["289", "Semprotan F 289", "13000000.0", 7, 25], ["47", "Manggis A 47", "5400000.0", 6, 25], ["377", "Sawah I", "10500000.0", 8, 25], ["76", "Sawah A", "11000000.0", 8, 25], ["324", "Mahoni", "6000000.0", 6, 25], ["399", "Manggis B", "5900000.0", 7, 25], ["216", "Mindi", "5600000.0", 6, 25], ["393", "Cilam A 393", "15800000.0", 10, 25], ["381", "Walang C", "11400000.0", 9, 25], ["379", "Melur D", "9800000.0", 9, 25], ["43", "Chibet B 43", "6300000.0", 7, 25], ["360", "Cemara A 360", "6200000.0", 7, 25], ["373", "Buntu F 373", "7700000.0", 7, 25], ["11", "Bambu B 11", "6800000.0", 6, 25], ["217", "Pedongkelan", "6200000.0", 7, 25], ["364", "Cipucang F 364", "8700000.0", 8, 25], ["395", "Jampea D", "5600000.0", 7, 25], ["330", "Asrama Yon Air", "7400000.0", 8, 25], ["342", "Beting G 342", "6900000.0", 8, 25], ["348", "Manunggal B", "16400000.0", 8, 25], ["336", "Tipar", "6000000.0", 7, 25], ["365", "Mawar C", "14800000.0", 9, 20], ["366", "UKA B", "6200000.0", 7, 20], ["42", "Buntu A 42", "8700000.0", 7, 25], ["334", "Cipucang 334", "6200000.0", 7, 25], ["389", "Mawar L", "5600000.0", 7, 20], ["387", "Mawar M", "15800000.0", 9, 20], ["385", "Mawar B", "11100000.0", 7, 20], ["38", "Pembangunan B", "6400000.0", 7, 25], ["346", "Kosambi", "6200000.0", 8, 25], ["24", "Cabe 24", "5300000.0", 6, 25], ["35", "Yaspi", "5900000.0", 7, 25], ["103", "Pembangunan C", "8000000.0", 10, 25], ["265", "Semprotan D", "11200000.0", 7, 25], ["341", "Yon Air", "5200000.0", 6, 25], ["29", "Sapi A", "6600000.0", 7, 25], ["391", "Buntu E 391", "14000000.0", 7, 25], ["17", "Jl. F B", "5400000.0", 7, 25], ["358", "Kakap B", "12300000.0", 11, 25], ["326", "Asrama DKI", "8600000.0", 9, 25], ["33", "Jl. F L 33", "4700000.0", 6, 25], ["344", "Beting H 344", "6000000.0", 7, 25], ["372", "Kampung Kandang A", "7400000.0", 8, 25], ["401", "Yon Air 401", "7300000.0", 9, 25], ["374", "Kampung Kandang B", "8600000.0", 9, 25], ["409", "Bebek D 409", "7200000.0", 7, 25], ["368", "Semprotan", "5500000.0", 8, 25], ["22", "Buntu A 22", "7400000.0", 8, 25], ["370", "Semprotan 370", "4100000.0", 7, 25], ["114", "Mawar 114", "8600000.0", 7, 25], ["116", "UKA C", "11300000.0", 9, 20], ["376", "Cipucang 376", "5800000.0", 7, 25], ["125", "UKA A", "11300000.0", 8, 20], ["126", "UKA D", "8100000.0", 7, 20], ["256", "Batu Tumbuh B 256", "6800000.0", 8, 25], ["411", "Kincir", "5800000.0", 7, 25], ["101", "Jl. B Lagoa 101", "9200000.0", 10, 20], ["366", "Cemara 366", "8800000.0", 10, 20], ["417", "Swadaya B", "7000000.0", 8, 25], ["378", "Cipucang 378", "9400000.0", 10, 25], ["50", "Bambu 50", "9000000.0", 7, 25], ["80", "Cipucang 80", "11500000.0", 10, 25], ["44", "Mini", "7300000.0", 7, 25], ["124", "Mantang 124", "11400000.0", 8, 20], ["392", "Walang C 392", "6000000.0", 7, 25], ["386", "Melur", "5500000.0", 7, 20], ["52", "BS 52", "9700000.0", 7, 25], ["388", "Walang A", "12900000.0", 10, 25], ["162", "Kapal 162", "24300000.0", 8, 20], ["380", "Buntu B 380", "6100000.0", 7, 25], ["55", "RW 02", "7500000.0", 8, 25], ["53", "Swadaya A", "6900000.0", 7, 25], ["390", "RW 01 C", "5400000.0", 6, 25], ["111", "BS 111", "9300000.0", 8, 25], ["394", "Jl. H RBU", "7800000.0", 8, 25], ["407", "Mawar 407", "6200000.0", 7, 25], ["396", "Mundu", "6400000.0", 7, 25], ["78", "Jl. A 78", "9000000.0", 8, 25], ["400", "Jl. A", "10500000.0", 8, 25], ["408", "Jampea", "8000000.0", 9, 25], ["146", "Sawah D", "12800000.0", 10, 25], ["120", "Sapi C", "18500000.0", 7, 25], ["107", "Bambu 107", "8200000.0", 7, 25], ["105", "Jalan B", "5700000.0", 7, 25], ["67", "Bebek A 67", "10700000.0", 7, 25], ["405", "Landak B", "7000000.0", 8, 25], ["414", "Semprotan J", "6200000.0", 7, 25], ["404", "Kapal 404", "8000000.0", 7, 20], ["382", "Mawar 382", "12400000.0", 8, 20], ["422", "Yon Air 422", "7200000.0", 8, 25], ["398", "Jl. B Lagoa 398", "8500000.0", 10, 25], ["420", "Jl. B Lagoa 420", "5100000.0", 7, 25], ["254", "Batu Tumbuh A 254", "6400000.0", 8, 25], ["384", "Mawar 384", "13000000.0", 9, 20], ["402", "Kampar", "5000000.0", 7, 25], ["147", "JL. F D", "10600000.0", 8, 25], ["406", "Landak C", "6900000.0", 8, 25], ["163", "Bambu 163", "10100000.0", 7, 20], ["81", "Mundu 81", "10000000.0", 8, 25], ["165", "Binangun C 165", "13300000.0", 10, 25], ["410", "Jl. F", "6200000.0", 7, 25], ["192", "Macan C", "20600000.0", 9, 20], ["70", "Kosambi 70", "8800000.0", 7, 16], ["418", "Bendungan Melayu A 418", "6300000.0", 8, 25], ["419", "Bendungan Melayu B", "7200000.0", 9, 25], ["98", "Binangun B 98", "11200000.0", 9, 25], ["127", "Tugu A", "12800000.0", 10, 25], ["429", "Walang E", "7900000.0", 10, 25], ["60", "Beting 60", "11700000.0", 9, 25], ["193", "Macan D", "12500000.0", 9, 20], ["425", "Kakap D", "5700000.0", 7, 25], ["119", "Sapi B", "25800000.0", 10, 25], ["424", "Kakap C", "6000000.0", 7, 25], ["92", "Jalan A 92", "8300000.0", 7, 20], ["128", "Bambu 128", "11800000.0", 9, 20], ["413", "Semprotan I", "5700000.0", 7, 25], ["104", "Kosambi 104", "7100000.0", 8, 25], ["436", "Kandang Sapi F", "4700000.0", 7, 25], ["169", "Kapal E 169", "11900000.0", 9, 25], ["144", "Kosambi 144", "9800000.0", 8, 20], ["427", "Sapi E", "5500000.0", 7, 25], ["432", "Bambu 432", "8000000.0", 8, 25], ["403", "Gang 3 403", "6000000.0", 7, 25], ["171", "Binangun D", "11200000.0", 10, 25], ["428", "Kelapa A", "5000000.0", 7, 25], ["45", "Kapal B 45", "10000000.0", 10, 25], ["428", "Tanah Merdeka B", "6600000.0", 9, 25], ["426", "Tanah Merah C", "7600000.0", 9, 25], ["178", "Kayu B", "9200000.0", 8, 20], ["121", "Bambu 121", "10200000.0", 9, 25], ["118", "Manunggal 118", "7800000.0", 7, 25], ["106", "Sate B", "6100000.0", 8, 25], ["56", "Sate A", "10500000.0", 8, 25], ["123", "Mantang 123", "11400000.0", 8, 15], ["421", "Jalan A", "5000000.0", 7, 25], ["99", "Lagoa", "9800000.0", 9, 25], ["130", "Korma B", "7500000.0", 8, 25], ["58", "Korma A", "9000000.0", 10, 25], ["73", "Korma C", "6800000.0", 7, 25], ["170", "Krematorium", "19100000.0", 8, 20], ["433", "Kelapa B", "6400000.0", 8, 25], ["65", "Bambu 65", "11200000.0", 9, 20], ["444", "Bhakti 444", "6800000.0", 8, 25], ["131", "Kelapa 131", "12100000.0", 7, 25], ["57", "Kelapa 57", "9300000.0", 8, 25], ["439", "Kelapa 439", "6400000.0", 7, 25], ["184", "Sawah Baru", "8900000.0", 8, 25], ["1", "Sawah 1", "11100000.0", 9, 25], ["155", "Merdeka A", "18300000.0", 8, 25], ["237", "Pelabuhan 237", "12000000.0", 8, 20], ["141", "Bhakti 141", "9200000.0", 7, 25], ["135", "RW 02 135", "9900000.0", 8, 25], ["233", "Pelabuhan 233", "13000000.0", 8, 20], ["236", "Pelabuhan 236", "14600000.0", 9, 20], ["439", "Nakula", "5600000.0", 7, 25], ["62", "RW 01 B 62", "15500000.0", 9, 25], ["117", "RW 01 A 117", "5000000.0", 6, 25], ["423", "Kampung Kandang", "7600000.0", 8, 25], ["214", "Walang B", "12700000.0", 10, 25], ["416", "Jl. B", "7800000.0", 9, 25], ["132", "Mundu 132", "9900000.0", 7, 25], ["139", "Beting 139", "9100000.0", 8, 25], ["140", "Beting 140", "9900000.0", 10, 25], ["109", "Cipucang 109", "7700000.0", 8, 25], ["143", "Pelelangan B", "9900000.0", 10, 25], ["431", "Cemara C", "7400000.0", 8, 25], ["435", "Kelapa Hijau", "5300000.0", 7, 25], ["434", "durian", "6800000.0", 8, 25], ["64", "Pelelangan A", "16500000.0", 11, 25], ["441", "mandiri", "8100000.0", 9, 25], ["40", "Kapling A", "10200000.0", 10, 20], ["314", "tipar timur 314", "7900000.0", 9, 25], ["308", "kelapa k 308", "8100000.0", 9, 25], ["34", "Mantang 34", "6500000.0", 7, 25], ["306", "Jalan A 306", "5300000.0", 7, 25], ["343", "mini A", "15800000.0", 9, 25], ["323", "melur g", "9400000.0", 8, 25], ["321", "mawar k", "9900000.0", 9, 25], ["317", "mawar E", "10900000.0", 10, 25], ["319", "mawar j", "7900000.0", 9, 25], ["329", "Jampea 329", "5600000.0", 7, 20], ["278", "rw 02. E", "7600000.0", 7, 25], ["04", "rw 02 c", "9800000.0", 9, 20], ["318", "mindi 318", "6200000.0", 7, 25], ["316", "mantang 316", "7000000.0", 8, 25], ["357", "Belimbing B 357", "6200000.0", 7, 25], ["339", "Merdeka B 339", "12600000.0", 7, 25], ["294", "kandang 294", "7400000.0", 8, 25], ["9", "kampung kandang 9", "8000000.0", 8, 25], ["284", "kampung kandang 284", "6500000.0", 8, 25], ["19", "Kandang 19", "8000000.0", 9, 25], ["298", "Beting Asem 298", "7900000.0", 9, 25], ["351", "Merin B", "7000000.0", 8, 25], ["325", "marine a 325", "10300000.0", 8, 25], ["311", "Banteng B 311", "7200000.0", 9, 25], ["290", "Belimbing 290", "6000000.0", 7, 25], ["279", "Pelabuhan A 279", "5000000.0", 7, 20], ["355", "pelabuhan b 355", "6600000.0", 7, 16], ["293", "jampea 293", "4800000.0", 6, 20], ["322", "Tipar 322", "7200000.0", 8, 25], ["295", "por timur 295", "6200000.0", 7, 16], ["305", "Jl.FG 305", "10000000.0", 10, 25], ["307", "jl. fH 307", "8800000.0", 9, 25], ["282", "keb. baru 282", "6600000.0", 8, 25], ["280", "kampung kurus 280", "5800000.0", 7, 20], ["327", "Gang Kelapa 327", "7000000.0", 9, 25], ["37", "Banten E 37", "9100000.0", 10, 25], ["20", "Jalan B 20", "6800000.0", 8, 25], ["361", "Angsana C 361", "5800000.0", 7, 25], ["15", "Tipar Timur", "9000000.0", 10, 25], ["349", "Kapling B", "6400000.0", 8, 20], ["315", "Lontar D", "11700000.0", 10, 25], ["313", "Lontar A", "8400000.0", 7, 25], ["28", "Marine D", "6600000.0", 7, 25], ["371", "Jalan F I", "7200000.0", 8, 20], ["292", "Blok R 292", "6000000.0", 7, 16], ["309", "Banteng A 309", "7400000.0", 9, 25], ["353", "lorong B", "5000000.0", 6, 25], ["337", "Mahoni A", "10400000.0", 10, 20], ["312", "Tipar 312", "6600000.0", 8, 25], ["335", "melur a", "16700000.0", 9, 20], ["304", "Jl.A 304", "6200000.0", 7, 25], ["369", "Cipucang E 369", "9600000.0", 10, 25], ["345", "Badak A 345", "14600000.0", 9, 20], ["5", "marine 5", "10000000.0", 10, 25], ["347", "Badak B 347", "6600000.0", 8, 20], ["302", "Banten F 302", "10200000.0", 10, 25], ["10", "Cabe C 10", "6200000.0", 7, 25], ["296", "Cabe D 296", "5800000.0", 6, 25], ["297", "Kelapa C", "18300000.0", 9, 25], ["300", "mantang 300", "6600000.0", 8, 25], ["320", "Tipar 320", "6000000.0", 7, 25], ["7", "jl. F A 7", "8800000.0", 9, 25], ["32", "Jl. F C 32", "9200000.0", 8, 20], ["363", "Jampea C 363", "7600000.0", 9, 25], ["247", "Deli  E  247", "5700000.0", 7, 20], ["255", "uka 255", "7000000.0", 7, 25], ["S. 249", "Melintang B 249", "7700000.0", 8, 25], ["S.90", "Melintang 90", "6400000.0", 8, 25], ["262", "Bhakti 262", "5900000.0", 9, 25], ["258", "Kampar B 258", "6000000.0", 7, 25], ["244", "Blok F A 244", "7800000.0", 8, 25], ["87", "Irnuf A 87", "6800000.0", 7, 25], ["229", "Dukuh  C  229", "9600000.0", 9, 25], ["264", "Bhakti 264", "5700000.0", 7, 25], ["271", "Jl. F F 271", "6400000.0", 7, 20], ["269", "Jl. F E 269", "7600000.0", 7, 20], ["31", "Lagoa 31", "6400000.0", 7, 25], ["275", "Duren A 275", "7400000.0", 8, 25], ["299", "Kelapa D", "19500000.0", 10, 25], ["277", "Sindang 277", "8500000.0", 10, 25], ["274", "Pepaya F 274", "7800000.0", 8, 25], ["272", "Pepaya E 272", "6600000.0", 8, 25], ["281", "Sindang 281", "6700000.0", 9, 20], ["267", "Manunggal C 267", "5800000.0", 7, 25], ["268", "Dukuh 268", "6200000.0", 6, 25], ["245", "Blok F B 245", "7400000.0", 7, 25], ["241", "Pasir D 241", "9000000.0", 10, 25], ["89", "Pasir A  89", "11500000.0", 9, 25], ["188", "Pasir  B  188", "6600000.0", 7, 25], ["21", "JL. B RBU A 21", "8500000.0", 10, 20], ["86", "Empang A 86", "6800000.0", 9, 25], ["291", "Sawah F 291", "8300000.0", 10, 20], ["97", "Kamboja A 97", "9200000.0", 8, 25], ["270", "Dukuh 270", "7200000.0", 8, 25], ["23", "Sawah C", "7000000.0", 7, 20], ["26", "JL. B2 RBU B 26", "8600000.0", 10, 20], ["276", "Mundu C 276", "7100000.0", 8, 25], ["359", "Beting F 359", "6400000.0", 7, 25], ["263", "Kamboja B", "4800000.0", 6, 25], ["301", "Lontar B 301", "8700000.0", 7, 25], ["2", "Bhakti 2", "5500000.0", 7, 25], ["253", "Bulak B 253", "10200000.0", 9, 25], ["16", "Kelapa G", "9100000.0", 9, 25], ["3", "Jalan A D", "8400000.0", 9, 25], ["286", "Marine E", "6200000.0", 7, 25], ["102", "Pelita B", "8800000.0", 8, 25], ["310", "Tipar 310", "5000000.0", 6, 25], ["283", "Sindang 283", "6600000.0", 9, 20], ["257", "Lorong 257", "6400000.0", 8, 25], ["252", "Kelapa B 252", "17500000.0", 8, 25], ["204", "Pasir C 204", "6400000.0", 7, 25], ["94", "Bhakti 94", "13900000.0", 10, 25], ["243", "Jl. B2 RBU C", "7200000.0", 8, 20], ["430", "UKA E 430", "8000000.0", 10, 25], ["225", "Deli A 225", "7500000.0", 9, 20], ["218", "Binangun G 218", "8700000.0", 10, 25], ["93", "Manunggal A 93", "9300000.0", 8, 25], ["205", "JLN . Blog G / 205", "2600000.0", 4, 20], ["248", "Deli F 248", "6200000.0", 7, 20], ["201", "Anggrek C / 201", "6400000.0", 7, 20], ["200", "Anggrek B / 200", "4400000.0", 6, 20], ["227", "Deli C 227", "9200000.0", 10, 20], ["234", "Pelabuhan A 234", "6400000.0", 9, 20], ["231", "Mantang F 231", "7200000.0", 8, 25], ["230", "Kosambi E 230", "6200000.0", 7, 25], ["232", "Mantang G 232", "8200000.0", 8, 25], ["235", "Kosambi F 235", "7900000.0", 7, 25], ["100", "Kampar A 100", "8600000.0", 10, 25], ["96", "Waru A 96", "5600000.0", 6, 25], ["238", "Dukuh A 238", "8400000.0", 8, 20], ["251", "Kelapa A 251", "19300000.0", 10, 25], ["199", "Kelapa j  / 199", "7400000.0", 8, 25], ["85", "Binangun A 85", "9800000.0", 10, 25], ["195", "Deperla B 195", "7000000.0", 7, 25], ["203", "Manggar B / 203", "8200000.0", 9, 25], ["202", "Manggar 202", "8400000.0", 9, 25], ["198", "Kelapa I / 198", "6600000.0", 8, 25], ["79", "Landak 79", "12200000.0", 8, 25], ["223", "Pepaya B 223", "6600000.0", 7, 20], ["191", "Bulak C 191", "10700000.0", 10, 25], ["228", "Sindang 228", "7800000.0", 9, 20], ["18", "Bebek B 18", "9800000.0", 10, 25], ["212", "Semprotan G 212", "4700000.0", 6, 25], ["211", "Semprotan C 211", "5600000.0", 6, 25], ["219", "Binangun H 219", "6600000.0", 9, 25], ["74", "Bambu 74", "9500000.0", 7, 25], ["190", "Bulak A 190", "9400000.0", 9, 25], ["220", "Rw 02 B 220", "15800000.0", 9, 20], ["285", "Dwi Tunggal 285", "11900000.0", 7, 25], ["182", "Banten 182", "7000000.0", 8, 25], ["239", "Dukuh B 239", "7200000.0", 7, 20], ["179", "Kosambi E 179", "6000000.0", 7, 25], ["273", "Beting E 273", "6800000.0", 8, 25], ["185", "Binangun F 185", "9200000.0", 10, 25], ["210", "Belimbing A 210", "7400000.0", 8, 25], ["242", "Bhakti 242", "7900000.0", 9, 25], ["206", "Jl. B Lagoa H 206", "9600000.0", 10, 20], ["6", "Anggrek A / 6", "7500000.0", 8, 20], ["215", "Banten 215", "7000000.0", 8, 25], ["261", "Irnuf B 261", "5800000.0", 7, 25], ["260", "Empang B 260", "6100000.0", 8, 25], ["266", "Jln B 266", "7800000.0", 8, 25], ["259", "Lorong 259", "6000000.0", 7, 20], ["250", "Pepaya D 250", "8000000.0", 8, 25], ["91", "Kosambi G 91", "11000000.0", 8, 25], ["213", "Melati A1 213", "10500000.0", 9, 20], ["177", "Bambu 177", "6400000.0", 7, 25], ["222", "Anggrek D 222", "5400000.0", 8, 25], ["83", "Banten 83", "7500000.0", 8, 25], ["208", "Beting D 208", "8200000.0", 8, 25], ["75", "Macan A 75", "7200000.0", 7, 25], ["167", "Buntu B 167", "17000000.0", 9, 25], ["95", "Pembangunan A 95", "6200000.0", 6, 25], ["164", "Jalan A Lagoa E 164", "8000000.0", 8, 15], ["176", "Bambu 176", "8200000.0", 8, 25], ["153", "Jl.B Lagoa 153", "5500000.0", 6, 25], ["71", "Kapal A 71", "9600000.0", 8, 25], ["154", "Jl.B Lagoa G 154", "6200000.0", 6, 25], ["108", "Cipucang B 108", "5200000.0", 6, 25], ["175", "Kapal C 175", "8000000.0", 8, 25], ["66", "Nelayan B 66", "10800000.0", 8, 25], ["8", "Mantang A", "8000000.0", 8, 25], ["168", "Kapal D 168", "8800000.0", 8, 25], ["303", "Lontar C 303", "8800000.0", 7, 25], ["158", "Mawar I 158", "5700000.0", 6, 25], ["112", "Mawar D 112", "8200000.0", 7, 25], ["367", "Cipucang D 367", "8800000.0", 10, 25], ["240", "Pepaca C 240", "7000000.0", 7, 20], ["287", "Kamboja C 287", "7400000.0", 8, 25], ["174", "Beting C 174", "8600000.0", 9, 25], ["331", "Por Timur 331", "6000000.0", 7, 20], ["82", "RW 02 82", "8700000.0", 8, 25], ["438", "Abror 438", "5900000.0", 7, 25], ["137", "Melur 137", "14400000.0", 9, 25], ["138", "Nelayan C 138", "9600000.0", 9, 25], ["226", "Deli B 226", "7200000.0", 8, 20], ["209", "Blok R A 209", "8700000.0", 10, 25], ["197", "Landak 197", "8600000.0", 7, 25], ["S. 196", "Macan F   S.196", "5200000.0", 7, 25], ["194", "Deperla A 194", "6800000.0", 7, 25], ["224", "Pepaya Raya A 224", "6200000.0", 7, 25], ["181", "Macan E / S. 181", "6100000.0", 7, 25], ["88", "Buntu 88", "8800000.0", 8, 25], ["180", "Kosambi F 180", "5800000.0", 7, 25], ["333", "Sindang C 333", "8200000.0", 9, 20], ["173", "Angsana B 173", "8200000.0", 8, 25], ["63", "Semprotan B 63", "6400000.0", 7, 25], ["221", "Rw 02 C 221", "15000000.0", 9, 20], ["77", "Nelayan C 77", "8000000.0", 7, 25], ["157", "UKA E 157", "7200000.0", 7, 25], ["161", "Pembangunan D 161", "5300000.0", 6, 25], ["54", "Bambu 54", "9300000.0", 8, 25], ["152", "Buntu 152", "9200000.0", 9, 25], ["113", "Mawar H 113", "8200000.0", 7, 25], ["183", "Banten 183", "6100000.0", 6, 25], ["186", "Nelayan D 186", "7500000.0", 7, 25]]
  
  result = [] 
  rows.each do |x|
    
    if x[2].to_i == 1200000 or x[2].to_i == 2200000
      result << x
    end
    
  end
  
  File.open("ss.csv", "w") {|f| f.write(rows.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""))}
end

task :problematic_glp => :environment do 
  rows = [[34, "S-1200K", 1200000], [38, "S-2200K", 2200000], [45, "S-1200K", 1200000], [49, "S-2200K", 2200000], [56, "S-1200K", 1200000], [60, "S-2200K", 2200000], [4, "1,2 juta 25m", 1200000], [8, "2,2 jt 25 m", 2200000], [23, "1,2 jt 20 m", 1200000], [27, "2,2 jt 20 m", 2200000], [74, "1,2 juta 25m - versi 2", 1200000], [75, "2,2 jt 25 m - versi 2", 2200000], [79, "S-1200k baru 16m", 1200000], [83, "S-2200k baru 16m", 2200000], [99, "1,2 jt 20 m baru", 1200000], [100, "2,2 jt 20 m baru", 2200000], [101, "2,2 jt 25 m baru", 2200000], [105, "S-1200k baru 10m", 1200000], [109, "S-2200k baru 10m", 2200000]]
  
  result = rows   
  
  File.open("glp.csv", "w") {|f| f.write(rows.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""))}
  
  
end

task :problematic_member => :environment do 
  rows = [["Sawah I 377", "Ermawati", "2608"], ["Sawah A 76", "Sarimanah", "1508"], ["Buntu F 373", "Ngatiyah", "1042"], ["Buntu F 373", "Nining Sunengsih", "1044"], ["Jalan B RBU A 27", "Panty Raharti", "2302"], ["Jalan B RBU A 27", "Fauziah", "2303"], ["Jalan B RBU A 27", "Rohaya", "2307"], ["Jalan B RBU A 27", "Endang Sri Rejeki", "2296"], ["Jalan B RBU A 27", "Endang Sri Astuti", "2298"], ["Buntu A 42", "Warsinah", "1048"], ["Buntu A 42", "Nurhani", "1041"], ["Walang C 381", "Sri Wahyuni", "2467"], ["Walang C 381", "Entik Rosmida", "2466"], ["Walang C 381", "Nursiyah", "2470"], ["Melur D 379", "Neng Arnasih", "2462"], ["Melur D 379", "Junaeni", "2461"], ["Mawar B 385", "Juriah", "1428"], ["Mawar M 387", "Liesnawaty", "1426"], ["Mawar M 387", "Farida", "1425"], ["Mawar M 387", "Nining Maharani", "1423"], ["Mawar M 387", "Sri Hartini", "1421"], ["Cipucang A 397", "Komariah", "4246"], ["Buntu E 391", "Aridah", "4229"], ["Cabe 24", "Sadikyah", "2260"], ["Pembangunan B 38", "Kupniah", "2517"], ["Manggis B 399", "Mariam", "1099"], ["Manggis A 47", "Sopani", "1096"], ["Mantang 415", "Marsinah", "4328"], ["Chibet B 43", "Baesri", "2510"], ["Sapi A 29", "Salamah", "2342"], ["Semprotan D 265", "Siti Hijriyah W", "4382"], ["Semprotan E 288", "Sadiyah", "282"], ["Merdeka D 356", "Agustini", "4370"], ["Kakap B 358", "Watiri", "2596"], ["Kakap B 358", "Odah", "1119"], ["Kakap B 358", "Maliatul Patimah", "1121"], ["Kakap A 51", "Sumiati", "1123"], ["Kakap A 51", "Salmah", "2592"], ["Kakap A 51", "Kastini", "2593"], ["Kakap A 51", "Sairi", "2597"], ["Cipucang F 364", "Siti Munawaroh", "2621"], ["Cipucang F 364", "Lina Alifudin", "2620"], ["Cipucang 80", "Nur Nengsih", "1579"], ["Kampung Kandang B 374", "Susi Mulyawati", "4412"], ["UKA C 116", "Farida Ernawati", "2743"], ["UKA C 116", "Fatimah Wisnu", "2746"], ["UKA C 116", "Surinah", "4440"], ["UKA A 125", "Leni Sahara", "2818"], ["Mantang 124", "Taryati", "2767"], ["Mawar 382", "Casmilah", "1392"], ["Mawar 384", "Ani Suminten", "1395"], ["Mawar 384", "Eka Wahyuni", "1398"], ["Mawar 384", "Kurniasih", "1399"], ["RW 02 55", "Saini", "2617"], ["RW 02 55", "Sri Mulyati", "1154"], ["RW 02 55", "Irma Mashandayani", "1153"], ["Walang C 392", "Rigir Dirgahayuningsih", "4499"], ["Jalan B Lagoa 398", "Robiyyati", "4537"], ["Jalan B Lagoa 101", "Maryani", "2570"], ["Jalan B Lagoa 101", "Sutinah", "2568"], ["Mundu 396", "Napiah", "4528"], ["Jl. H RBU", "Rini Muktiasih", "4518"], ["Bebek A 67", "Casmi", "544"], ["Mini 44", "Napisah", "1066"], ["Jampea 408", "Hertin Prihatin", "4607"], ["Jalan A 400", "Atiah", "1547"], ["Jalan A 78", "Titik Rohani", "2618"], ["Jalan A 78", "Siti Rahmah", "1550"], ["BS 52", "Emildah", "2656"], ["BS 52", "Casriyah", "1134"], ["Swadaya A 53", "Saniti", "376"], ["Swadaya B 417", "Neni Sumarni", "842"], ["Bambu 107", "Ikem Tjartali", "1151"], ["Bambu 107", "Yanih Ali Akbar", "1149"], ["Yon Air 422", "Eriawati Zalukhu", "4669"], ["BS 111", "Darmini", "1147"], ["Sawah D 146", "Soleha", "2886"], ["Sawah D 146", "Rusmiyati", "2884"], ["Semprotan I 413", "Nia Daniati", "1072"], ["Jalan A 92", "Dian Riyanti", "1784"], ["Jalan A 92", "Roeyati", "1782"], ["Jalan A 92", "Maunah", "1773"], ["Jalan A 92", "Jaenabun", "3018"], ["Jalan A 92", "Laela", "1786"], ["Sapi B 119", "Siti Hulaeti", "2747"], ["Macan D 193", "Karisah", "3098"], ["Beting 60", "Paula Veronika", "1197"], ["Tugu A 127", "Aminah", "2817"], ["Tugu A 127", "Sumiati ", "2811"], ["Bendungan Melayu B", "Masripah", "4708"], ["Macan C 192", "Darwinah", "308"], ["Binangun B 98", "Nani Susilawati", "1846"], ["Binangun B 98", "Linda Purwanti", "2992"], ["Binangun B 98", "Susilawati", "2991"], ["Binangun C 165", "Romlah", "1840"], ["Binangun D", "Yusriati", "3029"], ["Binangun D", "Munah", "3033"], ["Binangun D", "Munifah", "3034"], ["Bambu 65", "Inih", "889"], ["Walang B 214", "Yuyun Wahyuni", "3277"], ["Sate A 56", "Suhemi Dedi", "2694"], ["Sate A 56", "Miranti", "1170"], ["Sate A 56", "Sri Wahyuni", "1163"], ["Sate A 56", "Asmah Alijah", "1171"], ["Sate A 56", "Wasnah", "806"], ["Beting 140", "Soleha", "1647"], ["Beting 140", "Midah", "2856"], ["Korma A 58", "Fitria", "1177"], ["Korma A 58", "Jubaedah", "1182"], ["Korma C 73", "Yeni Sri Suprihatin", "2782"], ["Korma C 73", "Ratna", "2785"], ["Kapal E 169", "Sunarti", "3144"], ["Kapal E 169", "Kotijah", "3145"], ["Cipucang 109", "Klodiyah", "2705"], ["Cipucang 109", "Titi Sri Lubenah", "2707"], ["Cipucang 109", "Mulyasih", "2709"], ["Cipucang 109", "Aisah Mulyadi", "2706"], ["Kelapa 131", "Nuni Daryuni", "96"], ["Kelapa 131", "Erny Lupiyanti", "1172"], ["Kelapa 131", "Juriana", "2825"], ["Kelapa 439", "Siti Hadidjah", "150"], ["Sawah Baru", "Aan Anisah", "1910"], ["Sawah Baru", "Marwati Aceng", "1915"], ["Sawah Baru", "Lia Lisnawati", "3089"], ["Sawah Baru", "Nani", "3093"], ["Sawah 1", "Siti Aminah", "3087"], ["Sawah 1", "Lis Afniati", "3085"], ["Sawah 1", "Suryati", "1920"], ["Pelabuhan 237", "Nurhayati", "3447"], ["Pelelangan A", "Nurhayati", "2863"], ["Pelelangan A", "Darini", "2862"], ["mandiri", "Saanah", "4984"], ["Banten E 37", "Titin Supriatin", "2500"], ["Banten E 37", "Siti Haryani", "2490"], ["Kelapa G 16", "Yusningsih", "81"], ["Pelita B 102", "Elis", "2587"], ["Pelita B 102", "Eva Diana Sari", "2585"], ["Pelita B 102", "Maemunah", "2581"], ["Kelapa K 308", "Dumiati B", "1950"], ["Pelita B 102", "Amsiah", "2483"], ["Kelapa K 308", "Ma'anih", "2111"], ["Beting F 359", "Sujilah", "3989"], ["Tipar 15", "Halia", "2097"], ["Kapling A 40", "Ati", "2548"], ["Kapling A 40", "Farida Aryani. T", "2563"], ["Pelabuhan B 355", "Koriah", "4142"], ["Cipucang E 369", "Lia Sadiah", "4075"], ["Banten F 302", "Sri Mulyanah", "2489"], ["Banten F 302", "Sulyanah", "2493"], ["Banten F 302", "Watiah", "2499"], ["Marine 5", "Darini BT. Ismail", "1965"], ["Marine 5", "Warsih", "995"], ["Mantang 34", "Saleha", "2429"], ["Mantang 34", "Herni Usmiati", "2427"], ["Badak A 345", "Arwati", "2515"], ["Gang Kelapa 327", "Andi Sudarmi", "3896"], ["Cabe D 296", "Rotua Sianipar", "2063"], ["Cabe D 296", "Dursari", "2060"], ["Kandang 19", "Siti Aisah", "2160"], ["Melur G 323", "Yuyun Kurniasih", "2206"], ["Melur G 323", "Sanih", "2203"], ["Melur G 323", "Lusi Kurniasari", "2205"], ["Mawar E 317", "Ema Susanti", "2216"], ["Mawar E 317", "Ela Nurlela", "2217"], ["Mawar E 317", "Sapnah", "2214"], ["Mawar E 317", "Siti Rohani", "2218"], ["Kampung Kandang 9", "Wiwin", "2046"], ["Kampung Kandang 9", "Rupiah", "2040"], ["Marine E 286", "Sadiah", "2313"], ["Marine D 28", "Santi", "2311"], ["Lontar A 313", "Maemunah", "1892"], ["Lontar A 313", "Titin", "1894"], ["Lontar D 315", "Rokayah", "1900"], ["Lontar D 315", "Nurjanah", "1903"], ["Lontar D 315", "Rokayah", "1906"], ["Jalan A D 3", "Anah", "1940"], ["Jalan A D 3", "Dedeh Setiawati", "1944"], ["Jalan F G 305", "Siti Solicha", "2015"], ["Jalan F G 305", "Nuraedah", "2012"], ["Jalan F G 305", "Nurheni", "2400"], ["Jalan F A 7", "Sri Nurainy Anthoni", "2006"], ["Jalan F A 7", "Diana", "2002"], ["Jalan F A 7", "Rustianah", "2010"], ["RW 02 E 278", "Rahayu", "1959"], ["RW 02 E 278", "Ela Nurlaela", "1960"], ["RW 02 E 278", "Sariyanti", "1952"], ["RW 02 E 278", "Sumarti", "1947"], ["RW 02 C 4", "Desiyana", "1951"], ["RW 02 C 4", "Zeinatun", "1948"], ["RW 02 C 4", "Nurlaily Rahmah", "1955"], ["RW 02 C 4", "Kamsia", "1953"], ["Mantang 300", "Devi Aryanti", "3960"], ["Lontar B 301", "Ani Rohimah", "1974"], ["Lontar B 301", "A. Kuraisin", "1975"], ["Sawah F 291", "Sahria", "2252"], ["Sawah C 23", "Tati Sunarti", "2247"], ["Sawah C 23", "Nur Amaliyah", "2251"], ["Kamboja C 287", "Jumaene", "596"], ["Kamboja A 97", "Nani S.", "590"], ["Kamboja A 97", "Ayu Zukriah", "1837"], ["Kamboja A 97", "Marijah", "1838"], ["Duren A 275", "Siti Aminah", "3648"], ["Duren A 275", "Ijah", "3649"], ["Mawar J 319", "Fatimah", "2224"], ["Sindang 283", "Juhayati", "3711"], ["Dwi Tunggal 285", "Gusmaniarti", "655"], ["Dwi Tunggal 285", "Imasse", "661"], ["Dwi Tunggal 285", "Fatmawati", "656"], ["Dukuh 268", "Siti Nur Alipiah", "3617"], ["RW 02 C 4", "Your Bertha", "1957"], ["Jalan F E 269", "Leli Milina", "2393"], ["Jalan F E 269", "Tinur Sidabutar", "2397"], ["Jalan F E 269", "Yuningsih", "2402"], ["Jalan F E 269", "Ida Nurlela", "2405"], ["Jalan F E 269", "Wulan Desi", "3658"], ["Jalan F F 271", "Sayuri", "2398"], ["Jalan F C 32", "Riska Juliyanti", "2403"], ["Jalan F C 32", "Avrianti Nurfatihah", "2395"], ["Jalan F C 32", "Eva Sari Nurullita", "2406"], ["Jalan F C 32", "Fittroh Dewi Lestari", "2404"], ["Jalan F C 32", "Sari Trisnawati", "2394"], ["Jalan F C 32", "Siti Kusmiati", "2408"], ["Jalan F C 32", "Sumarni", "3656"], ["Irnuf A 87", "Ita Yanti", "1718"], ["Bhakti 242", "Rukmi Kurniawati", "1929"], ["Bhakti 242", "Roaesah", "1928"], ["Dukuh  C  229", "Indah Yuning Prapti", "3497"], ["Dukuh  C  229", "Sumiati", "3496"], ["Dukuh  C  229", "Lusi Darni", "3499"], ["Blok F B 245", "Djaenah", "3471"], ["Blok F B 245", "Sumyati", "3475"], ["Blok F A 244", "Siti Andayani", "3466"], ["Pasir A  89", "Tursinah", "948"], ["Jalan B RBU C 243", "Muniroh", "2286"], ["Jalan B RBU A 21", "Windani", "3510"], ["Jalan B RBU B 26", "Siti Aisah", "2289"], ["Jalan B RBU B 26", "Suryati", "2293"], ["Jalan B RBU B 26", "Ai Nurhasanah", "2284"], ["Waru A 96", "Rasiti", "403"], ["Dukuh B 239", "Djumanah", "3390"], ["Dukuh B 239", "Rosita", "3394"], ["Dukuh B 239", "Rahayu Boko Pangestuti", "3395"], ["Dukuh A 238", "Anzani Sundrawati", "3388"], ["Dukuh A 238", "Erna Jaeni", "3384"], ["Kosambi E 230", "Nurbaya", "447"], ["Kosambi G 91", "Intan Purnamasari", "940"], ["Mantang G 232", "Siti Latifah", "3378"], ["Mantang G 232", "Aliyah", "3379"], ["Mantang G 232", "Aas Hasanah", "3377"], ["Bebek B 18", "Rusmini", "981"], ["Bebek B 18", "Jumiati", "983"], ["Bebek B 18", "Kuryati", "984"], ["Pepaya B 223", "Tjartijem", "3324"], ["Binangun G 218", "Muda Wamah", "1677"], ["RW 02 C 221", "Rini Lestari", "3340"], ["RW 02 C 221", "Ratiyah", "3338"], ["RW 02 B 220", "Suci Rahayu", "3363"], ["Melati A1 213", "Karmi", "2132"], ["Melati A1 213", "Rohimah", "2133"], ["Belimbing A 210", "Aisyah", "3246"], ["Belimbing A 210", "Nemy", "3245"], ["Beting D 208", "Hartati", "3260"], ["Beting D 208", "Sulastri", "3261"], ["Deperla B 195", "Eva Riany", "3226"], ["Jalan B Lagoa H 206", "Titin", "3208"], ["Deperla A 194", "Erni Yuniati", "3218"], ["Deperla A 194", "Nursea", "3219"], ["Kelapa J 199", "Masriah", "41"], ["Landak 197", "Cucu Sumiati", "1289"], ["Landak 197", "Nurneneng", "1555"], ["Macan A 75", "Sarah Ayu Aulia", "1497"], ["Macan A 75", "Engkar Sulastri", "1498"], ["Binangun F 185", "Kartini", "1680"], ["Binangun A 85", "Nurhayati", "1668"], ["Binangun A 85", "Tati", "1671"], ["Banten 83", "Titik R", "1632"], ["Banten 83", "Ratinah", "1631"], ["Banten 83", "Martha Beluwa", "1630"], ["Bulak C 191", "Anah", "1593"], ["Bulak A 190", "Neni", "1595"], ["Bulak A 190", "Wattiny", "1597"], ["Bulak A 190", "Sumini", "1596"], ["Bambu 74", "Siti Warsinah", "511"], ["Bambu 74", "Muhayaroh", "1235"], ["Bambu 176", "Herlina", "1524"], ["Bambu 176", "Cawi", "316"], ["Beting C 174", "Kasti Sri Asri", "3054"], ["Angsana B 173", "Kusiah", "3050"], ["Angsana B 173", "Suryati", "3043"], ["Jalan A Lagoa E 164", "Hernawati", "3027"], ["Jalan A Lagoa E 164", "Siti Khodijah", "3023"], ["Kapal D 168", "Suryati", "896"], ["Kapal D 168", "Sulastri", "203"], ["Kapal D 168", "Wiwi Sunarti", "225"], ["Mawar D 112", "Inah", "1482"], ["Mawar D 112", "Kasniti", "1484"], ["Mawar H 113", "Rahayu", "1488"], ["Nelayan C 138", "Junesih", "1246"], ["Buntu 88", "Taniah", "1744"], ["Buntu 88", "Ferry Rahayu", "1754"], ["Buntu 88", "Bahariah", "1742"], ["Buntu 88", "Juarsih", "1751"], ["Buntu 152", "Sairoh", "2916"], ["UKA E 157", "Nehati", "2928"], ["UKA E 157", "Rujiatun", "2926"], ["Mawar I 158", "Sopiah", "2936"], ["Mawar I 158", "Nenti Mayasari", "2938"], ["Pembangunan A 95", "Sri Susanti", "1813"], ["Pembangunan A 95", "Sutini", "1812"], ["Jalan B Lagoa G 154", "Sri Neni", "2986"], ["Pepaya C 240", "Udimah", "3356"], ["Pepaya C 240", "Yanih B Marjuki", "3358"], ["Bambu 54", "Tati Rusniah", "1145"], ["Melur 137", "Hesty Hartaty", "1684"]]
  
  
  
  result = rows   
  
  File.open("member.csv", "w") {|f| f.write(rows.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""))}
   
end




=begin
Mapper 

GroupLoan.all.map{|x| x.}


array = []
GroupLoan.all.each do |gl|
  result_array = []
  result_array << gl.group_number
  result_array << gl.name
  result_array << gl.start_fund.to_s
  result_array << gl.active_group_loan_memberships.count 
  result_array << gl.number_of_meetings
  
  array << result_array
end


array = []
GroupLoanProduct.all.each do |glp|
  result_array = []
  result_array << glp.id 
  result_array << glp.name
  result_array << glp.disbursed_principal.to_i
  array << result_array 
end


array = []
GroupLoanProduct.all.each do |glp|
  next if not ( glp.disbursed_principal.to_i == 1200000 or glp.disbursed_principal.to_i == 2200000 ) 
  
  result_array = []
  result_array << glp.id 
  result_array << glp.name
  result_array << glp.disbursed_principal.to_i
  array << result_array 
end



no
start_fund
active_member
total_meeting 



=end
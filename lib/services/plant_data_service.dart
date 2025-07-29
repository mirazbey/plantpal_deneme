// lib/services/plant_data_service.dart (YENİ DOSYA)
import 'package:plantpal/pages/plant_search_page.dart'; // PlantSearchResult modelini kullanmak için

class PlantDataService {
  // Bütün bitki veritabanımız artık bu dosyada!
  // Yönetmesi ve yeni bitki eklemesi çok daha kolay.
  static List<PlantSearchResult> getPlants() {
    // Set kullanarak benzersiz bitkileri saklayacağız.
    // Eşitliği doğru kontrol edebilmek için PlantSearchResult sınıfında
    // == operatörü ve hashCode override edilmelidir.
    final uniquePlants = <PlantSearchResult>{};

    // Orijinal listeyi alın ve benzersiz sete eklemeye çalışın.
    // Set, zaten mevcut olan öğelerin tekrar eklenmesine izin vermez.
    uniquePlants.addAll([
      //////////////////1. SIRA///////////////////////////////////////
      PlantSearchResult(
          commonName: 'Paşa Kılıcı',
          scientificName: 'Sansevieria trifasciata',
          imagePath: 'Snake Plant'),
      PlantSearchResult(
          commonName: 'Devetabanı',
          scientificName: 'Monstera deliciosa',
          imagePath: 'Monstera deliciosa'),
      PlantSearchResult(
          commonName: 'Barış Çiçeği',
          scientificName: 'Spathiphyllum wallisii',
          imagePath: 'Peace Lily'),
      PlantSearchResult(
          commonName: 'Aşk Merdiveni',
          scientificName: 'Nephrolepis exaltata',
          imagePath: 'Boston Fern'),
      PlantSearchResult(
          commonName: 'Kurdele Çiçeği',
          scientificName: 'Chlorophytum comosum',
          imagePath: 'Spider Plant'),
      PlantSearchResult(
          commonName: 'Aloe Vera',
          scientificName: 'Aloe barbadensis miller',
          imagePath: 'Aloe Vera'),
      PlantSearchResult(
          commonName: 'Kauçuk Bitkisi',
          scientificName: 'Ficus elastica',
          imagePath: 'Rubber Plant'),
      PlantSearchResult(
          commonName: 'Salon Sarmaşığı',
          scientificName: 'Epipremnum aureum',
          imagePath: 'Golden Pothos'),
      PlantSearchResult(
          commonName: 'Dua Çiçeği',
          scientificName: 'Maranta leuconeura',
          imagePath: 'Prayer Plant'),
      PlantSearchResult(
          commonName: 'Benjamin',
          scientificName: 'Ficus benjamina',
          imagePath: 'Ficus benjamina'),
      PlantSearchResult(
          commonName: 'Kalanşo',
          scientificName: 'Kalanchoe blossfeldiana',
          imagePath: 'Kalanchoe'),
      PlantSearchResult(
          commonName: 'Çin Herdemyeşili',
          scientificName: 'Aglaonema commutatum',
          imagePath: 'Chinese Evergreen'),
      PlantSearchResult(
          commonName: 'Salon Gülü',
          scientificName: 'Hibiscus rosa-sinensis',
          imagePath: 'Hibiscus'),
      PlantSearchResult(
          commonName: 'Para Ağacı',
          scientificName: 'Pachira aquatica',
          imagePath: 'Money Tree'),
      PlantSearchResult(
          commonName: 'Şeflera',
          scientificName: 'Schefflera arboricola',
          imagePath: 'Umbrella Tree'),
      PlantSearchResult(
          commonName: 'Yelken Çiçeği',
          scientificName: 'Anthurium andraeanum',
          imagePath: 'Anthurium'),
      PlantSearchResult(
          commonName: 'Zamia',
          scientificName: 'Zamioculcas zamiifolia',
          imagePath: 'ZZ Plant'),
      PlantSearchResult(
          commonName: 'Begonya',
          scientificName: 'Begonia semperflorens',
          imagePath: 'Begonia'),
      // PlantSearchResult(commonName: 'Kurdele', scientificName: 'Chlorophytum comosum', imagePath: 'Spider Plant'), // Duplicate of Kurdele Çiçeği
      PlantSearchResult(
          commonName: 'Ortanca',
          scientificName: 'Hydrangea macrophylla',
          imagePath: 'Hydrangea'),
      PlantSearchResult(
          commonName: 'Sukulent',
          scientificName: 'Echeveria elegans',
          imagePath: 'Succulent Plant'),
      PlantSearchResult(
          commonName: 'Şans Bambusu',
          scientificName: 'Dracaena sanderiana',
          imagePath: 'Lucky Bamboo'),
      // PlantSearchResult(commonName: 'Kurdele Çiçeği', scientificName: 'Chlorophytum comosum', imagePath: 'Chlorophytum comosum'), // Duplicate of Kurdele Çiçeği
      PlantSearchResult(
          commonName: 'Sarmaşık İnciri',
          scientificName: 'Ficus pumila',
          imagePath: 'Creeping Fig'),
      PlantSearchResult(
          commonName: 'Kılıç Çiçeği',
          scientificName: 'Sansevieria cylindrica',
          imagePath: 'Sansevieria cylindrica'),
      PlantSearchResult(
          commonName: 'Telgraf Çiçeği',
          scientificName: 'Tradescantia zebrina',
          imagePath: 'Wandering Jew'),
      PlantSearchResult(
          commonName: 'Zebra Kaktüs',
          scientificName: 'Haworthiopsis fasciata',
          imagePath: 'Zebra Haworthia'),
      // PlantSearchResult(commonName: 'Kurdele Otu', scientificName: 'Chlorophytum comosum', imagePath: 'Chlorophytum'), // Duplicate of Kurdele Çiçeği
      PlantSearchResult(
          commonName: 'Biberiye',
          scientificName: 'Rosmarinus officinalis',
          imagePath: 'Rosemary Plant'),
      PlantSearchResult(
          commonName: 'Lavanta',
          scientificName: 'Lavandula angustifolia',
          imagePath: 'Lavender'),
      PlantSearchResult(
          commonName: 'İngiliz Sarmaşığı',
          scientificName: 'Hedera helix',
          imagePath: 'English Ivy'),
      PlantSearchResult(
          commonName: 'Aşkın Gözyaşları',
          scientificName: 'Sedum morganianum',
          imagePath: 'Burro\'s Tail'),
      PlantSearchResult(
          commonName: 'Kaktüs',
          scientificName: 'Mammillaria elongata',
          imagePath: 'Golden Stars Cactus'),
      PlantSearchResult(
          commonName: 'Atatürk Çiçeği',
          scientificName: 'Euphorbia pulcherrima',
          imagePath: 'Poinsettia'),
      PlantSearchResult(
          commonName: 'Yılbaşı Kaktüsü',
          scientificName: 'Schlumbergera truncata',
          imagePath: 'Christmas Cactus'),
      PlantSearchResult(
          commonName: 'Afrika Menekşesi',
          scientificName: 'Saintpaulia ionantha',
          imagePath: 'African Violet'),
      PlantSearchResult(
          commonName: 'Euphorbia',
          scientificName: 'Euphorbia milii',
          imagePath: 'Crown of Thorns'),
      PlantSearchResult(
          commonName: 'Dracaena',
          scientificName: 'Dracaena marginata',
          imagePath: 'Dragon Tree'),
      PlantSearchResult(
          commonName: 'Areka Palmiyesi',
          scientificName: 'Dypsis lutescens',
          imagePath: 'Areca Palm'),
      PlantSearchResult(
          commonName: 'Bonsai',
          scientificName: 'Ficus microcarpa',
          imagePath: 'Bonsai Tree'),
      PlantSearchResult(
          commonName: 'Yuka',
          scientificName: 'Yucca elephantipes',
          imagePath: 'Yucca Plant'),
      PlantSearchResult(
          commonName: 'Nolina',
          scientificName: 'Beaucarnea recurvata',
          imagePath: 'Ponytail Palm'),
      // PlantSearchResult(commonName: 'Kurdele', scientificName: 'Chlorophytum comosum', imagePath: 'Airplane Plant'), // Duplicate of Kurdele Çiçeği
      PlantSearchResult(
          commonName: 'Kalatea',
          scientificName: 'Calathea ornata',
          imagePath: 'Calathea'),
      PlantSearchResult(
          commonName: 'Açelya',
          scientificName: 'Rhododendron simsii',
          imagePath: 'Azalea'),
      PlantSearchResult(
          commonName: 'Skulent',
          scientificName: 'Sedum rubrotinctum',
          imagePath: 'Jelly Bean Plant'),
      PlantSearchResult(
          commonName: 'Sarmaşık',
          scientificName: 'Epipremnum pinnatum',
          imagePath: 'Devil\'s Ivy'),
      PlantSearchResult(
          commonName: 'Kurdele Çiçeği',
          scientificName: 'Chlorophytum laxum',
          imagePath: 'Chlorophytum laxum'),
      PlantSearchResult(
          commonName: 'Küpe Çiçeği',
          scientificName: 'Fuchsia magellanica',
          imagePath: 'Fuchsia'),
      PlantSearchResult(
          commonName: 'Limon Ağacı',
          scientificName: 'Citrus limon',
          imagePath: 'Lemon Tree'),
      //////////////////2. SIRA///////////////////////////////////////
      PlantSearchResult(
          commonName: 'Fil Kulağı',
          scientificName: 'Alocasia macrorrhiza',
          imagePath: 'Elephant Ear Plant'),
      PlantSearchResult(
          commonName: 'Şimşir',
          scientificName: 'Buxus sempervirens',
          imagePath: 'Boxwood'),
      PlantSearchResult(
          commonName: 'Sarmaşık Gülü',
          scientificName: 'Rosa banksiae',
          imagePath: 'Lady Banks Rose'),
      PlantSearchResult(
          commonName: 'Kamelya',
          scientificName: 'Camellia japonica',
          imagePath: 'Camellia'),
      PlantSearchResult(
          commonName: 'Nilüfer',
          scientificName: 'Nymphaea alba',
          imagePath: 'Water Lily'),
      PlantSearchResult(
          commonName: 'Zakkum',
          scientificName: 'Nerium oleander',
          imagePath: 'Oleander'),
      PlantSearchResult(
          commonName: 'Sardunya',
          scientificName: 'Pelargonium hortorum',
          imagePath: 'Geranium'),
      PlantSearchResult(
          commonName: 'Fesleğen',
          scientificName: 'Ocimum basilicum',
          imagePath: 'Basil Plant'),
      PlantSearchResult(
          commonName: 'Mine Çiçeği',
          scientificName: 'Lantana camara',
          imagePath: 'Lantana'),
      PlantSearchResult(
          commonName: 'Kadife Çiçeği',
          scientificName: 'Tagetes erecta',
          imagePath: 'Marigold'),
      PlantSearchResult(
          commonName: 'Tavşan Kulağı',
          scientificName: 'Monilaria obconica',
          imagePath: 'Bunny Succulent'),
      PlantSearchResult(
          commonName: 'Şemsiye Bitkisi',
          scientificName: 'Cyperus alternifolius',
          imagePath: 'Umbrella Plant'),
      PlantSearchResult(
          commonName: 'Kertenkele Kuyruğu',
          scientificName: 'Peperomia caperata',
          imagePath: 'Ripple Peperomia'),
      PlantSearchResult(
          commonName: 'Kırlangıç Otu',
          scientificName: 'Chelidonium majus',
          imagePath: 'Greater Celandine'),
      PlantSearchResult(
          commonName: 'Aslanağzı',
          scientificName: 'Antirrhinum majus',
          imagePath: 'Snapdragon Flower'),
      PlantSearchResult(
          commonName: 'Şakayık',
          scientificName: 'Paeonia lactiflora',
          imagePath: 'Peony Flower'),
      PlantSearchResult(
          commonName: 'Kasımpatı',
          scientificName: 'Chrysanthemum morifolium',
          imagePath: 'Chrysanthemum'),
      PlantSearchResult(
          commonName: 'Gelin Çiçeği',
          scientificName: 'Gypsophila paniculata',
          imagePath: 'Baby\'s Breath'),
      PlantSearchResult(
          commonName: 'Süs Lahanası',
          scientificName: 'Brassica oleracea var. acephala',
          imagePath: 'Ornamental Cabbage'),
      PlantSearchResult(
          commonName: 'Ejderha Kanı',
          scientificName: 'Dracaena draco',
          imagePath: 'Dragon Tree'),
      PlantSearchResult(
          commonName: 'Sarmaşık Begonya',
          scientificName: 'Cissus rhombifolia',
          imagePath: 'Grape Ivy'),
      PlantSearchResult(
          commonName: 'Ebegümeci',
          scientificName: 'Malva sylvestris',
          imagePath: 'Common Mallow'),
      PlantSearchResult(
          commonName: 'Kaktüs İnciri',
          scientificName: 'Opuntia ficus-indica',
          imagePath: 'Prickly Pear'),
      PlantSearchResult(
          commonName: 'Karaçam',
          scientificName: 'Pinus nigra',
          imagePath: 'Black Pine'),
      PlantSearchResult(
          commonName: 'Süs Kirazı',
          scientificName: 'Prunus serrulata',
          imagePath: 'Japanese Cherry Blossom'),
      PlantSearchResult(
          commonName: 'Mimoza',
          scientificName: 'Mimosa pudica',
          imagePath: 'Sensitive Plant'),
      PlantSearchResult(
          commonName: 'Kutsal Fesleğen',
          scientificName: 'Ocimum tenuiflorum',
          imagePath: 'Holy Basil'),
      PlantSearchResult(
          commonName: 'Sedum',
          scientificName: 'Sedum acre',
          imagePath: 'Stonecrop'),
      PlantSearchResult(
          commonName: 'Lilyum',
          scientificName: 'Lilium candidum',
          imagePath: 'Madonna Lily'),
      PlantSearchResult(
          commonName: 'Dikenli İncir',
          scientificName: 'Opuntia microdasys',
          imagePath: 'Bunny Ear Cactus'),
      PlantSearchResult(
          commonName: 'Süs Biberi',
          scientificName: 'Capsicum annuum',
          imagePath: 'Ornamental Pepper'),
      PlantSearchResult(
          commonName: 'Zambak',
          scientificName: 'Lilium longiflorum',
          imagePath: 'Easter Lily'),
      PlantSearchResult(
          commonName: 'Horozibiği',
          scientificName: 'Celosia argentea',
          imagePath: 'Cockscomb Flower'),
      PlantSearchResult(
          commonName: 'Süs Elması',
          scientificName: 'Malus floribunda',
          imagePath: 'Crabapple Tree'),
      PlantSearchResult(
          commonName: 'Renkli Kılıç',
          scientificName: 'Cordyline fruticosa',
          imagePath: 'Ti Plant'),
      PlantSearchResult(
          commonName: 'Adaçayı',
          scientificName: 'Salvia officinalis',
          imagePath: 'Sage Plant'),
      PlantSearchResult(
          commonName: 'Ekinazya',
          scientificName: 'Echinacea purpurea',
          imagePath: 'Purple Coneflower'),
      PlantSearchResult(
          commonName: 'Kırmızı Yapraklı Kolyoz',
          scientificName: 'Coleus scutellarioides',
          imagePath: 'Coleus Plant'),
      PlantSearchResult(
          commonName: 'Biberiye Çalısı',
          scientificName: 'Rosmarinus prostratus',
          imagePath: 'Prostrate Rosemary'),
      PlantSearchResult(
          commonName: 'Sardun',
          scientificName: 'Pelargonium peltatum',
          imagePath: 'Ivy Geranium'),
      PlantSearchResult(
          commonName: 'Kurdela Sarmaşığı',
          scientificName: 'Tradescantia fluminensis',
          imagePath: 'Small-leaf Spiderwort'),
      PlantSearchResult(
          commonName: 'Gece Güzeli',
          scientificName: 'Cestrum nocturnum',
          imagePath: 'Night-blooming Jasmine'),
      PlantSearchResult(
          commonName: 'Yasemin',
          scientificName: 'Jasminum polyanthum',
          imagePath: 'Jasmine Plant'),
      PlantSearchResult(
          commonName: 'Melisa',
          scientificName: 'Melissa officinalis',
          imagePath: 'Lemon Balm'),
      PlantSearchResult(
          commonName: 'Katırtırnağı',
          scientificName: 'Ononis spinosa',
          imagePath: 'Restharrow'),
      PlantSearchResult(
          commonName: 'Melek Trompeti',
          scientificName: 'Brugmansia suaveolens',
          imagePath: 'Angel\'s Trumpet'),
      PlantSearchResult(
          commonName: 'Lavanta Çalısı',
          scientificName: 'Lavandula stoechas',
          imagePath: 'French Lavender'),
      PlantSearchResult(
          commonName: 'Çuha Çiçeği',
          scientificName: 'Primula vulgaris',
          imagePath: 'Primrose'),
      PlantSearchResult(
          commonName: 'Yıldız Çiçeği',
          scientificName: 'Dahlia pinnata',
          imagePath: 'Dahlia Flower'),
      //////////////////3. SIRA///////////////////////////////////////
      PlantSearchResult(
          commonName: 'Pilea',
          scientificName: 'Pilea peperomioides',
          imagePath: 'Chinese Money Plant'),
      PlantSearchResult(
          commonName: 'Küçük Şemsiye',
          scientificName: 'Cyperus involucratus',
          imagePath: 'Umbrella Sedge'),
      PlantSearchResult(
          commonName: 'Fittonia',
          scientificName: 'Fittonia albivenis',
          imagePath: 'Nerve Plant'),
      PlantSearchResult(
          commonName: 'Kokulu Sardunya',
          scientificName: 'Pelargonium graveolens',
          imagePath: 'Scented Geranium'),
      PlantSearchResult(
          commonName: 'Kum Zambağı',
          scientificName: 'Pancratium maritimum',
          imagePath: 'Sea Daffodil'),
      PlantSearchResult(
          commonName: 'Cam Güzeli',
          scientificName: 'Impatiens walleriana',
          imagePath: 'Busy Lizzie'),
      PlantSearchResult(
          commonName: 'Salon Eğreltisi',
          scientificName: 'Asplenium nidus',
          imagePath: 'Bird\'s Nest Fern'),
      PlantSearchResult(
          commonName: 'Zambak Çiçeği',
          scientificName: 'Crinum asiaticum',
          imagePath: 'Spider Lily'),
      PlantSearchResult(
          commonName: 'Peygamber Kılıcı',
          scientificName: 'Sansevieria masoniana',
          imagePath: 'Whale Fin Sansevieria'),
      PlantSearchResult(
          commonName: 'Gelin Duvağı',
          scientificName: 'Stephanotis floribunda',
          imagePath: 'Madagascar Jasmine'),
      PlantSearchResult(
          commonName: 'Kedi Tırnağı',
          scientificName: 'Acalypha hispida',
          imagePath: 'Chenille Plant'),
      PlantSearchResult(
          commonName: 'Ejder Meyvesi Kaktüsü',
          scientificName: 'Hylocereus undatus',
          imagePath: 'Dragon Fruit Cactus'),
      PlantSearchResult(
          commonName: 'Çöl Gülü',
          scientificName: 'Adenium obesum',
          imagePath: 'Desert Rose'),
      PlantSearchResult(
          commonName: 'Guzmanya',
          scientificName: 'Guzmania lingulata',
          imagePath: 'Guzmania'),
      PlantSearchResult(
          commonName: 'Kardelen',
          scientificName: 'Galanthus nivalis',
          imagePath: 'Snowdrop'),
      PlantSearchResult(
          commonName: 'Musa Cüce Muz',
          scientificName: 'Musa acuminata',
          imagePath: 'Dwarf Banana Plant'),
      PlantSearchResult(
          commonName: 'Nilüfer Kaktüs',
          scientificName: 'Astrophytum asterias',
          imagePath: 'Star Cactus'),
      PlantSearchResult(
          commonName: 'Kurbağa Ağacı',
          scientificName: 'Fatsia japonica',
          imagePath: 'Japanese Aralia'),
      PlantSearchResult(
          commonName: 'Kurdele Saksısı',
          scientificName: 'Aspidistra elatior',
          imagePath: 'Cast Iron Plant'),
      PlantSearchResult(
          commonName: 'Alev Çalısı',
          scientificName: 'Photinia × fraseri',
          imagePath: 'Red Tip Photinia'),
      PlantSearchResult(
          commonName: 'Süs Nergisi',
          scientificName: 'Narcissus tazetta',
          imagePath: 'Paperwhite Narcissus'),
      PlantSearchResult(
          commonName: 'Yılbaşı Gülü',
          scientificName: 'Helleborus niger',
          imagePath: 'Christmas Rose'),
      PlantSearchResult(
          commonName: 'Mandalina Ağacı',
          scientificName: 'Citrus reticulata',
          imagePath: 'Mandarin Tree'),
      PlantSearchResult(
          commonName: 'Bambu Palmiyesi',
          scientificName: 'Chamaedorea seifrizii',
          imagePath: 'Bamboo Palm'),
      PlantSearchResult(
          commonName: 'Kaktüs Topu',
          scientificName: 'Echinocactus grusonii',
          imagePath: 'Golden Barrel Cactus'),
      PlantSearchResult(
          commonName: 'Yılanyastığı',
          scientificName: 'Arisaema triphyllum',
          imagePath: 'Jack in the Pulpit'),
      PlantSearchResult(
          commonName: 'Buz Çiçeği',
          scientificName: 'Delosperma cooperi',
          imagePath: 'Ice Plant'),
      PlantSearchResult(
          commonName: 'Fırça Çalısı',
          scientificName: 'Callistemon citrinus',
          imagePath: 'Bottlebrush Plant'),
      PlantSearchResult(
          commonName: 'Kına Çiçeği',
          scientificName: 'Lawsonia inermis',
          imagePath: 'Henna Plant'),
      PlantSearchResult(
          commonName: 'Yılan Kaktüs',
          scientificName: 'Aporocactus flagelliformis',
          imagePath: 'Rat Tail Cactus'),
      PlantSearchResult(
          commonName: 'Dizigotheca',
          scientificName: 'Schefflera elegantissima',
          imagePath: 'False Aralia'),
      PlantSearchResult(
          commonName: 'Kozalak Çiçeği',
          scientificName: 'Banksia integrifolia',
          imagePath: 'Banksia'),
      PlantSearchResult(
          commonName: 'Kar Topu Çalısı',
          scientificName: 'Viburnum opulus',
          imagePath: 'Snowball Bush'),
      PlantSearchResult(
          commonName: 'Mercan Otu',
          scientificName: 'Russelia equisetiformis',
          imagePath: 'Firecracker Plant'),
      PlantSearchResult(
          commonName: 'Çöl Alevi',
          scientificName: 'Leonotis leonurus',
          imagePath: 'Lion\'s Tail'),
      PlantSearchResult(
          commonName: 'Biberiye Benzeri',
          scientificName: 'Westringia fruticosa',
          imagePath: 'Coastal Rosemary'),
      PlantSearchResult(
          commonName: 'Sarı Karanfil',
          scientificName: 'Dianthus caryophyllus',
          imagePath: 'Yellow Carnation'),
      PlantSearchResult(
          commonName: 'Ayçiçeği',
          scientificName: 'Helianthus annuus',
          imagePath: 'Sunflower'),
      PlantSearchResult(
          commonName: 'Ateş Çiçeği',
          scientificName: 'Salvia splendens',
          imagePath: 'Scarlet Sage'),
      PlantSearchResult(
          commonName: 'Yosun Gülü',
          scientificName: 'Portulaca grandiflora',
          imagePath: 'Moss Rose'),
      PlantSearchResult(
          commonName: 'Mavi Çiçekli Kolyoz',
          scientificName: 'Plectranthus scutellarioides',
          imagePath: 'Coleus Blue'),
      PlantSearchResult(
          commonName: 'Gri Lavanta',
          scientificName: 'Lavandula lanata',
          imagePath: 'Woolly Lavender'),
      PlantSearchResult(
          commonName: 'Ejderha Ağacı',
          scientificName: 'Dracaena marginata bicolor',
          imagePath: 'Bicolor Dragon Tree'),
      PlantSearchResult(
          commonName: 'Yılan Derisi Bitkisi',
          scientificName: 'Sansevieria ehrenbergii',
          imagePath: 'Blue Sansevieria'),
      PlantSearchResult(
          commonName: 'Kırmızı Telgraf Çiçeği',
          scientificName: 'Tradescantia spathacea',
          imagePath: 'Moses-in-the-Cradle'),
      PlantSearchResult(
          commonName: 'Kurşun Otu',
          scientificName: 'Plumbago auriculata',
          imagePath: 'Plumbago'),
      PlantSearchResult(
          commonName: 'Zebra Bitkisi',
          scientificName: 'Aphelandra squarrosa',
          imagePath: 'Zebra Plant'),
      PlantSearchResult(
          commonName: 'Beyaz Küpe Çiçeği',
          scientificName: 'Fuchsia boliviana alba',
          imagePath: 'White Fuchsia'),
      PlantSearchResult(
          commonName: 'Karanfil',
          scientificName: 'Dianthus barbatus',
          imagePath: 'Sweet William'),
      //////////////////4. SIRA///////////////////////////////////////
      PlantSearchResult(
          commonName: 'Yıldız Patı',
          scientificName: 'Scabiosa stellata',
          imagePath: 'Starflower Scabiosa'),
      PlantSearchResult(
          commonName: 'Aşk Çiçeği',
          scientificName: 'Tradescantia pallida',
          imagePath: 'Purple Heart Plant'),
      PlantSearchResult(
          commonName: 'Bakır Rengi Kolyoz',
          scientificName: 'Solenostemon scutellarioides',
          imagePath: 'Copper Coleus'),
      PlantSearchResult(
          commonName: 'Kuraklık Sardunyası',
          scientificName: 'Pelargonium sidoides',
          imagePath: 'South African Geranium'),
      PlantSearchResult(
          commonName: 'Tavus Kuşu Bitkisi',
          scientificName: 'Calathea makoyana',
          imagePath: 'Peacock Plant'),
      PlantSearchResult(
          commonName: 'Mızrak Yapraklı Dieffenbachia',
          scientificName: 'Dieffenbachia seguine',
          imagePath: 'Dumb Cane'),
      PlantSearchResult(
          commonName: 'Lanetli Çiçek',
          scientificName: 'Helleborus orientalis',
          imagePath: 'Lenten Rose'),
      PlantSearchResult(
          commonName: 'Kutup Bitkisi',
          scientificName: 'Saxifraga oppositifolia',
          imagePath: 'Purple Saxifrage'),
      PlantSearchResult(
          commonName: 'Asparagus Sarmaşığı',
          scientificName: 'Asparagus densiflorus',
          imagePath: 'Asparagus Fern'),
      PlantSearchResult(
          commonName: 'Yılbaşı Kolyozu',
          scientificName: 'Plectranthus amboinicus',
          imagePath: 'Cuban Oregano'),
      PlantSearchResult(
          commonName: 'Küçük Top Kaktüs',
          scientificName: 'Parodia magnifica',
          imagePath: 'Ball Cactus'),
      PlantSearchResult(
          commonName: 'Gümüş Dolar Ağacı',
          scientificName: 'Xerosicyos danguyi',
          imagePath: 'Silver Dollar Vine'),
      PlantSearchResult(
          commonName: 'Sarmaşık Gül',
          scientificName: 'Rosa hybrid climber',
          imagePath: 'Climbing Rose'),
      PlantSearchResult(
          commonName: 'Yıldızlı Kalanşo',
          scientificName: 'Kalanchoe pinnata',
          imagePath: 'Air Plant'),
      PlantSearchResult(
          commonName: 'Yelpaze Palmiyesi',
          scientificName: 'Licuala grandis',
          imagePath: 'Fan Palm'),
      PlantSearchResult(
          commonName: 'Küpeli Çiçek',
          scientificName: 'Abutilon hybridum',
          imagePath: 'Flowering Maple'),
      PlantSearchResult(
          commonName: 'Kristal Çiçeği',
          scientificName: 'Mesembryanthemum crystallinum',
          imagePath: 'Ice Plant Crystalline'),
      PlantSearchResult(
          commonName: 'Yılan Yüzü',
          scientificName: 'Caladium bicolor',
          imagePath: 'Fancy Leaf Caladium'),
      PlantSearchResult(
          commonName: 'İnci Tanesi Çiçeği',
          scientificName: 'Senecio rowleyanus',
          imagePath: 'String of Pearls'),
      PlantSearchResult(
          commonName: 'Kalp Kalbe Karşı',
          scientificName: 'Ceropegia woodii',
          imagePath: 'String of Hearts'),
      PlantSearchResult(
          commonName: 'Karpuz Peperomia',
          scientificName: 'Peperomia argyreia',
          imagePath: 'Watermelon Peperomia'),
      PlantSearchResult(
          commonName: 'Kedi Kuyruğu',
          scientificName: 'Acalypha pendula',
          imagePath: 'Dwarf Chenille'),
      PlantSearchResult(
          commonName: 'Kıvırcık Maranta',
          scientificName: 'Calathea rufibarba',
          imagePath: 'Velvet Calathea'),
      PlantSearchResult(
          commonName: 'Pembe Karanfil',
          scientificName: 'Dianthus plumarius',
          imagePath: 'Cottage Pink'),
      PlantSearchResult(
          commonName: 'Düğün Çiçeği',
          scientificName: 'Ranunculus asiaticus',
          imagePath: 'Persian Buttercup'),
      PlantSearchResult(
          commonName: 'Gri Adaçayı',
          scientificName: 'Salvia leucantha',
          imagePath: 'Mexican Bush Sage'),
      PlantSearchResult(
          commonName: 'Aytaşı Çiçeği',
          scientificName: 'Senecio mandraliscae',
          imagePath: 'Blue Chalksticks'),
      PlantSearchResult(
          commonName: 'Bonzai Ardıç',
          scientificName: 'Juniperus procumbens',
          imagePath: 'Japanese Garden Juniper'),
      PlantSearchResult(
          commonName: 'Kırmızı Biber Ağacı',
          scientificName: 'Capsicum frutescens',
          imagePath: 'Chili Pepper Plant'),
      PlantSearchResult(
          commonName: 'Peygamber Devesi Bitkisi',
          scientificName: 'Stapelia gigantea',
          imagePath: 'Carrion Flower'),
      // PlantSearchResult(commonName: 'Lavanta Çalısı', scientificName: 'Perovskia atriplicifolia', imagePath: 'Russian Sage'), // Duplicate of Lavanta Çalısı (Lavandula stoechas)
      PlantSearchResult(
          commonName: 'Yosun Saksısı',
          scientificName: 'Selaginella kraussiana',
          imagePath: 'Club Moss'),
      PlantSearchResult(
          commonName: 'Beyaz Karanfil',
          scientificName: 'Dianthus caryophyllus alba',
          imagePath: 'White Carnation'),
      PlantSearchResult(
          commonName: 'Kahkaha Çiçeği',
          scientificName: 'Mirabilis jalapa',
          imagePath: 'Four O\'Clock Flower'),
      PlantSearchResult(
          commonName: 'Hindistan Cevizi Palmiyesi',
          scientificName: 'Cocos nucifera',
          imagePath: 'Coconut Tree'),
      PlantSearchResult(
          commonName: 'Buzul Sardunyası',
          scientificName: 'Erodium reichardii',
          imagePath: 'Alpine Geranium'),
      PlantSearchResult(
          commonName: 'Sarı Gül',
          scientificName: 'Rosa banksiae lutea',
          imagePath: 'Yellow Banksia Rose'),
      PlantSearchResult(
          commonName: 'Kırmızı Antoryum',
          scientificName: 'Anthurium andraeanum',
          imagePath: 'Red Anthurium'),
      PlantSearchResult(
          commonName: 'Pembe Lale',
          scientificName: 'Tulipa gesneriana',
          imagePath: 'Pink Tulip'),
      PlantSearchResult(
          commonName: 'Pembe Kuşkonmaz',
          scientificName: 'Asparagus sprengeri',
          imagePath: 'Sprenger\'s Asparagus'),
      PlantSearchResult(
          commonName: 'Sarmaşık Hanımeli',
          scientificName: 'Lonicera japonica',
          imagePath: 'Japanese Honeysuckle'),
      PlantSearchResult(
          commonName: 'Kırmızı Ortanca',
          scientificName: 'Hydrangea macrophylla red',
          imagePath: 'Red Hydrangea'),
      PlantSearchResult(
          commonName: 'Gülhatmi',
          scientificName: 'Alcea rosea',
          imagePath: 'Hollyhock'),
      PlantSearchResult(
          commonName: 'Gümüş Çalı',
          scientificName: 'Leucophyta brownii',
          imagePath: 'Cushion Bush'),
      PlantSearchResult(
          commonName: 'Kırmızı Kadife',
          scientificName: 'Celosia plumosa',
          imagePath: 'Red Cockscomb'),
      PlantSearchResult(
          commonName: 'Sümbülteber',
          scientificName: 'Polianthes tuberosa',
          imagePath: 'Tuberose'),
      PlantSearchResult(
          commonName: 'Pembe Kasımpatı',
          scientificName: 'Chrysanthemum pink',
          imagePath: 'Pink Chrysanthemum'),
      PlantSearchResult(
          commonName: 'Gökkuşağı Kolyoz',
          scientificName: 'Coleus rainbow mix',
          imagePath: 'Rainbow Coleus'),
      //////////////////5. SIRA///////////////////////////////////////
      PlantSearchResult(
          commonName: 'Cennet Bambusu',
          scientificName: 'Nandina domestica',
          imagePath: 'Nandina domestica'),
      // PlantSearchResult(commonName: 'Çin Herdemyeşili', scientificName: 'Aglaonema modestum', imagePath: 'Aglaonema modestum'), // Duplicate of Çin Herdemyeşili
      // PlantSearchResult(commonName: 'Alev Çalısı', scientificName: 'Photinia fraseri', imagePath: 'Photinia fraseri'), // Duplicate of Alev Çalısı (Photinia × fraseri)
      PlantSearchResult(
          commonName: 'Zeytin Ağacı',
          scientificName: 'Olea europaea',
          imagePath: 'Olea europaea'),
      // PlantSearchResult(commonName: 'Limon Ağacı', scientificName: 'Citrus limon', imagePath: 'Citrus limon'), // Duplicate of Limon Ağacı
      PlantSearchResult(
          commonName: 'Tespih Ağacı',
          scientificName: 'Melia azedarach',
          imagePath: 'Melia azedarach'),
      // PlantSearchResult(commonName: 'Begonya', scientificName: 'Begonia semperflorens', imagePath: 'Begonia semperflorens'), // Duplicate of Begonya
      // PlantSearchResult(commonName: 'Zakkum', scientificName: 'Nerium oleander', imagePath: 'Nerium oleander'), // Duplicate of Zakkum
      // PlantSearchResult(commonName: 'Açelya', scientificName: 'Rhododendron simsii', imagePath: 'Rhododendron simsii'), // Duplicate of Açelya
      // PlantSearchResult(commonName: 'Nilüfer', scientificName: 'Nymphaea alba', imagePath: 'Nymphaea alba'), // Duplicate of Nilüfer
      PlantSearchResult(
          commonName: 'Frenk Üzümü',
          scientificName: 'Ribes rubrum',
          imagePath: 'Ribes rubrum'),
      PlantSearchResult(
          commonName: 'Defne',
          scientificName: 'Laurus nobilis',
          imagePath: 'Laurus nobilis'),
      PlantSearchResult(
          commonName: 'Manolya',
          scientificName: 'Magnolia grandiflora',
          imagePath: 'Magnolia grandiflora'),
      // PlantSearchResult(commonName: 'Küpe Çiçeği', scientificName: 'Fuchsia hybrida', imagePath: 'Fuchsia hybrida'), // Duplicate of Küpe Çiçeği
      PlantSearchResult(
          commonName: 'Kara Dut',
          scientificName: 'Morus nigra',
          imagePath: 'Morus nigra'),
      PlantSearchResult(
          commonName: 'Ayı Kulak Çiçeği',
          scientificName: 'Bergenia cordifolia',
          imagePath: 'Bergenia cordifolia'),
      // PlantSearchResult(commonName: 'Akşamsefası', scientificName: 'Mirabilis jalapa', imagePath: 'Mirabilis jalapa'), // Duplicate of Kahkaha Çiçeği
      // PlantSearchResult(commonName: 'Kasımpatı', scientificName: 'Chrysanthemum morifolium', imagePath: 'Chrysanthemum morifolium'), // Duplicate of Kasımpatı
      // PlantSearchResult(commonName: 'Dikenli İncir', scientificName: 'Opuntia ficus-indica', imagePath: 'Opuntia ficus-indica'), // Duplicate of Kaktüs İnciri
      // PlantSearchResult(commonName: 'Küstüm Otu', scientificName: 'Mimosa pudica', imagePath: 'Mimosa pudica'), // Duplicate of Mimoza
      PlantSearchResult(
          commonName: 'Oya Ağacı',
          scientificName: 'Lagerstroemia indica',
          imagePath: 'Lagerstroemia indica'),
      PlantSearchResult(
          commonName: 'Arap Yasemini',
          scientificName: 'Jasminum sambac',
          imagePath: 'Jasminum sambac'),
      // PlantSearchResult(commonName: 'Lavantin', scientificName: 'Lavandula stoechas', imagePath: 'Lavandula stoechas'), // Duplicate of Lavanta Çalısı
      PlantSearchResult(
          commonName: 'Mor Salkım',
          scientificName: 'Wisteria sinensis',
          imagePath: 'Wisteria sinensis'),
      // PlantSearchResult(commonName: 'İstanbul Lalesi', scientificName: 'Tulipa gesneriana', imagePath: 'Tulipa gesneriana'), // Duplicate of Pembe Lale
      PlantSearchResult(
          commonName: 'Bonsai İnciri',
          scientificName: 'Ficus retusa',
          imagePath: 'Ficus retusa'),
      // PlantSearchResult(commonName: 'Tavşan Kulağı', scientificName: 'Monilaria obconica', imagePath: 'Monilaria obconica'), // Duplicate of Tavşan Kulağı
      // PlantSearchResult(commonName: 'Yuka Palmiyesi', scientificName: 'Yucca elephantipes', imagePath: 'Yucca elephantipes'), // Duplicate of Yuka
      PlantSearchResult(
          commonName: 'Cennet Kuşu Çiçeği',
          scientificName: 'Strelitzia reginae',
          imagePath: 'Strelitzia reginae'),
      PlantSearchResult(
          commonName: 'Köpek Dişi Bitkisi',
          scientificName: 'Cynodon dactylon',
          imagePath: 'Cynodon dactylon'),
      // PlantSearchResult(commonName: 'Sarmaşık Gülü', scientificName: 'Rosa banksiae', imagePath: 'Rosa banksiae'), // Duplicate of Sarmaşık Gülü
      // PlantSearchResult(commonName: 'Yıldız Çiçeği', scientificName: 'Dahlia pinnata', imagePath: 'Dahlia pinnata'), // Duplicate of Yıldız Çiçeği
      PlantSearchResult(
          commonName: 'Kılıç Çiçeği',
          scientificName: 'Hippeastrum striatum',
          imagePath: 'Hippeastrum striatum'),
      PlantSearchResult(
          commonName: 'Alacalı Kauçuk',
          scientificName: 'Ficus elastica Tineke',
          imagePath: 'Ficus elastica Tineke'),
      // PlantSearchResult(commonName: 'Sarı Çuha Çiçeği', scientificName: 'Primula vulgaris', imagePath: 'Primula vulgaris'), // Duplicate of Çuha Çiçeği
      PlantSearchResult(
          commonName: 'İtalyan Ardıcı',
          scientificName: 'Juniperus communis',
          imagePath: 'Juniperus communis'),
      // PlantSearchResult(commonName: 'Adaçayı', scientificName: 'Salvia officinalis', imagePath: 'Salvia officinalis'), // Duplicate of Adaçayı
      PlantSearchResult(
          commonName: 'Sakallı İris',
          scientificName: 'Iris germanica',
          imagePath: 'Iris germanica'),
      PlantSearchResult(
          commonName: 'Tavşan Kulağı Sukulent',
          scientificName: 'Kalanchoe tomentosa',
          imagePath: 'Kalanchoe tomentosa'),
      PlantSearchResult(
          commonName: 'Şeker Kamışı',
          scientificName: 'Saccharum officinarum',
          imagePath: 'Saccharum officinarum'),
      PlantSearchResult(
          commonName: 'Hurma Ağacı',
          scientificName: 'Phoenix dactylifera',
          imagePath: 'Phoenix dactylifera'),
      PlantSearchResult(
          commonName: 'Yasemin Sarmaşığı',
          scientificName: 'Trachelospermum jasminoides',
          imagePath: 'Trachelospermum jasminoides'),
      PlantSearchResult(
          commonName: 'Ginkgo Ağacı',
          scientificName: 'Ginkgo biloba',
          imagePath: 'Ginkgo biloba'),
      PlantSearchResult(
          commonName: 'Kestane Ağacı',
          scientificName: 'Castanea sativa',
          imagePath: 'Castanea sativa'),
      PlantSearchResult(
          commonName: 'Zencefil Çiçeği',
          scientificName: 'Alpinia purpurata',
          imagePath: 'Alpinia purpurata'),
      PlantSearchResult(
          commonName: 'Portakal Ağacı',
          scientificName: 'Citrus sinensis',
          imagePath: 'Citrus sinensis'),
      // PlantSearchResult(commonName: 'Yılbaşı Kaktüsü', scientificName: 'Schlumbergera truncata', imagePath: 'Schlumbergera truncata'), // Duplicate of Yılbaşı Kaktüsü
      // PlantSearchResult(commonName: 'Kırmızı Yapraklı Kolyoz', scientificName: 'Coleus blumei', imagePath: 'Coleus blumei'), // Duplicate of Kırmızı Yapraklı Kolyoz
      PlantSearchResult(
          commonName: 'Nilüfer Sümbülü',
          scientificName: 'Eichhornia crassipes',
          imagePath: 'Eichhornia crassipes'),
      // PlantSearchResult(commonName: 'Tavşan Kulağı', scientificName: 'Monilaria obconica', imagePath: 'Monilaria obconica'), // Duplicate of Tavşan Kulağı
      // PlantSearchResult(commonName: 'Zebra Bitkisi', scientificName: 'Aphelandra squarrosa', imagePath: 'Aphelandra squarrosa'), // Duplicate of Zebra Bitkisi
      // PlantSearchResult(commonName: 'Panda Bitkisi', scientificName: 'Kalanchoe tomentosa', imagePath: 'Kalanchoe tomentosa'), // Duplicate of Tavşan Kulağı Sukulent
      // PlantSearchResult(commonName: 'Çöl Gülü', scientificName: 'Adenium obesum', imagePath: 'Adenium obesum'), // Duplicate of Çöl Gülü
      // PlantSearchResult(commonName: 'At Kuyruğu Palmiyesi', scientificName: 'Beaucarnea recurvata', imagePath: 'Beaucarnea recurvata'), // Duplicate of Nolina
      // PlantSearchResult(commonName: 'Kauçuk Ağacı', scientificName: 'Ficus elastica', imagePath: 'Ficus elastica'), // Duplicate of Kauçuk Bitkisi
      // PlantSearchResult(commonName: 'Fil Kulağı', scientificName: 'Alocasia macrorrhiza', imagePath: 'Alocasia macrorrhiza'), // Duplicate of Fil Kulağı
      // PlantSearchResult(commonName: 'Kızıl Damar Bitkisi', scientificName: 'Fittonia albivenis', imagePath: 'Fittonia albivenis'), // Duplicate of Fittonia
      PlantSearchResult(
          commonName: 'Kanarya Sarmaşığı',
          scientificName: 'Senecio angulatus',
          imagePath: 'Senecio angulatus'),
      PlantSearchResult(
          commonName: 'Altın Zincir Kaktüs',
          scientificName: 'Parodia leninghausii',
          imagePath: 'Parodia leninghausii'),
      PlantSearchResult(
          commonName: 'Kalp Yapraklı Philodendron',
          scientificName: 'Philodendron hederaceum',
          imagePath: 'Philodendron hederaceum'),
      PlantSearchResult(
          commonName: 'Çam Şemsiye',
          scientificName: 'Sciadopitys verticillata',
          imagePath: 'Sciadopitys verticillata'),
      PlantSearchResult(
          commonName: 'Mozambik Ejderhası',
          scientificName: 'Dracaena afromontana',
          imagePath: 'Dracaena afromontana'),
      // PlantSearchResult(commonName: 'Hint Fesleğeni', scientificName: 'Ocimum tenuiflorum', imagePath: 'Holy basil'), // Duplicate of Kutsal Fesleğen
      PlantSearchResult(
          commonName: 'Kahve Bitkisi',
          scientificName: 'Coffea arabica',
          imagePath: 'Coffea arabica'),
      // PlantSearchResult(commonName: 'Ejder Meyvesi Kaktüsü', scientificName: 'Hylocereus undatus', imagePath: 'Hylocereus undatus'), // Duplicate of Ejder Meyvesi Kaktüsü
      PlantSearchResult(
          commonName: 'Sarımsak Sarmaşığı',
          scientificName: 'Tulbaghia violacea',
          imagePath: 'Tulbaghia violacea'),
      // PlantSearchResult(commonName: 'Süs Biberi', scientificName: 'Capsicum annuum', imagePath: 'Ornamental pepper plant'), // Duplicate of Süs Biberi
      // PlantSearchResult(commonName: 'Kına Ağacı', scientificName: 'Lawsonia inermis', imagePath: 'Lawsonia inermis'), // Duplicate of Kına Çiçeği
      PlantSearchResult(
          commonName: 'Limon Otu',
          scientificName: 'Cymbopogon citratus',
          imagePath: 'Lemongrass plant'),
      PlantSearchResult(
          commonName: 'Kurt Pençesi',
          scientificName: 'Selaginella lepidophylla',
          imagePath: 'Selaginella lepidophylla'),
      PlantSearchResult(
          commonName: 'Sultan Sarmaşığı',
          scientificName: 'Ipomoea purpurea',
          imagePath: 'Ipomoea purpurea'),
      PlantSearchResult(
          commonName: 'Kına Çiçeği',
          scientificName: 'Impatiens balsamina',
          imagePath: 'Impatiens balsamina'),
      // PlantSearchResult(commonName: 'Cennet Kuşu', scientificName: 'Strelitzia reginae', imagePath: 'Strelitzia reginae'), // Duplicate of Cennet Kuşu Çiçeği
      PlantSearchResult(
          commonName: 'Yarasa Çiçeği',
          scientificName: 'Tacca chantrieri',
          imagePath: 'Tacca chantrieri'),
      PlantSearchResult(
          commonName: 'Kral Bromelyası',
          scientificName: 'Aechmea fasciata',
          imagePath: 'Aechmea fasciata'),
      // PlantSearchResult(commonName: 'Asparagus Sarmaşığı', scientificName: 'Asparagus densiflorus', imagePath: 'Asparagus densiflorus'), // Duplicate of Asparagus Sarmaşığı
      PlantSearchResult(
          commonName: 'Kırmızı Kalp Bitkisi',
          scientificName: 'Hoya kerrii',
          imagePath: 'Hoya kerrii'),
      // PlantSearchResult(commonName: 'Zeytin Ağacı', scientificName: 'Olea europaea', imagePath: 'Olea europaea'), // Duplicate of Zeytin Ağacı
      PlantSearchResult(
          commonName: 'Şeytanın Dili',
          scientificName: 'Amorphophallus konjac',
          imagePath: 'Amorphophallus konjac'),
      PlantSearchResult(
          commonName: 'Bozkır Gülü',
          scientificName: 'Eustoma grandiflorum',
          imagePath: 'Eustoma grandiflorum'),
      // PlantSearchResult(commonName: 'Sarmaşık İncir', scientificName: 'Ficus pumila', imagePath: 'Ficus pumila'), // Duplicate of Sarmaşık İnciri
      // PlantSearchResult(commonName: 'Gri Lavanta', scientificName: 'Lavandula angustifolia', imagePath: 'Lavandula angustifolia'), // Duplicate of Gri Lavanta
      PlantSearchResult(
          commonName: 'Çilek Begonyası',
          scientificName: 'Saxifraga stolonifera',
          imagePath: 'Saxifraga stolonifera'),
      PlantSearchResult(
          commonName: 'Parfüm Çiçeği',
          scientificName: 'Plumeria rubra',
          imagePath: 'Plumeria rubra'),
      // PlantSearchResult(commonName: 'Yosun Gülü', scientificName: 'Portulaca grandiflora', imagePath: 'Portulaca grandiflora'), // Duplicate of Yosun Gülü
      // PlantSearchResult(commonName: 'Süs Nergisi', scientificName: 'Narcissus tazetta', imagePath: 'Narcissus tazetta'), // Duplicate of Süs Nergisi
      PlantSearchResult(
          commonName: 'Madagaskar Ejderhası',
          scientificName: 'Dracaena marginata',
          imagePath: 'Dracaena marginata'),
      // PlantSearchResult(commonName: 'Yılbaşı Kaktüsü', scientificName: 'Schlumbergera truncata', imagePath: 'Schlumbergera truncata'), // Duplicate of Yılbaşı Kaktüsü
      PlantSearchResult(
          commonName: 'Siyah Gül Begonyası',
          scientificName: 'Begonia rex',
          imagePath: 'Begonia rex'),
      PlantSearchResult(
          commonName: 'Mavi Göz',
          scientificName: 'Nemophila menziesii',
          imagePath: 'Baby blue eyes flower'),
      PlantSearchResult(
          commonName: 'Havlu Çiçeği',
          scientificName: 'Achimenes longiflora',
          imagePath: 'Achimenes longiflora'),
      // PlantSearchResult(commonName: 'Altın Sarmaşık', scientificName: 'Epipremnum aureum', imagePath: 'Epipremnum aureum'), // Duplicate of Salon Sarmaşığı
      PlantSearchResult(
          commonName: 'Yeşim Bitkisi',
          scientificName: 'Crassula ovata',
          imagePath: 'Crassula ovata'),
      // PlantSearchResult(commonName: 'Kırmızı Kedi Kuyruğu', scientificName: 'Acalypha hispida', imagePath: 'Acalypha hispida'), // Duplicate of Kedi Tırnağı
      PlantSearchResult(
          commonName: 'Peygamber Çiçeği',
          scientificName: 'Centaurea cyanus',
          imagePath: 'Centaurea cyanus'),
      // PlantSearchResult(commonName: 'Yıldız Çiçeği', scientificName: 'Dahlia pinnata', imagePath: 'Dahlia pinnata'), // Duplicate of Yıldız Çiçeği
      // PlantSearchResult(commonName: 'Melek Borusu', scientificName: 'Brugmansia suaveolens', imagePath: 'Brugmansia suaveolens'), // Duplicate of Melek Trompeti
      PlantSearchResult(
          commonName: 'Yılan Ağacı',
          scientificName: 'Dracaena reflexa',
          imagePath: 'Dracaena reflexa'),
      PlantSearchResult(
          commonName: 'Alev Çalısı',
          scientificName: 'Euphorbia cotinifolia',
          imagePath: 'Euphorbia cotinifolia'),
    ]);

    // Set'i List'e çevir ve geri döndür.
    return uniquePlants.toList();
  }
}

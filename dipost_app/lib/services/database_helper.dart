import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dipost.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Création des tables
    await db.execute('''
      CREATE TABLE utilisateurs (
        id_utilisateur INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        adresse_email TEXT UNIQUE NOT NULL,
        mot_de_passe TEXT NOT NULL,
        telephone TEXT,
        role TEXT NOT NULL,
        auth_code TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ibox (
        id_ibox INTEGER PRIMARY KEY AUTOINCREMENT,
        adresse TEXT NOT NULL,
        capacite INTEGER NOT NULL,
        statut TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE colis (
        id_colis INTEGER PRIMARY KEY AUTOINCREMENT,
        id_ibox INTEGER,
        id_destinataire INTEGER NOT NULL,
        id_expediteur INTEGER NOT NULL,
        contenu TEXT NOT NULL,
        statut TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (id_ibox) REFERENCES ibox (id_ibox),
        FOREIGN KEY (id_destinataire) REFERENCES utilisateurs (id_utilisateur),
        FOREIGN KEY (id_expediteur) REFERENCES utilisateurs (id_utilisateur)
      )
    ''');

    await db.execute('''
      CREATE TABLE livraisons (
        id_livraison INTEGER PRIMARY KEY AUTOINCREMENT,
        id_colis INTEGER NOT NULL,
        id_livreur INTEGER NOT NULL,
        date_livraison TEXT,
        statut_livraison TEXT NOT NULL,
        FOREIGN KEY (id_colis) REFERENCES colis (id_colis),
        FOREIGN KEY (id_livreur) REFERENCES utilisateurs (id_utilisateur)
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id_notification INTEGER PRIMARY KEY AUTOINCREMENT,
        id_utilisateur INTEGER NOT NULL,
        message TEXT NOT NULL,
        type_notification TEXT NOT NULL,
        statut TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs (id_utilisateur)
      )
    ''');

    await db.execute('''
      CREATE TABLE signatures (
        id_signature INTEGER PRIMARY KEY AUTOINCREMENT,
        id_utilisateur INTEGER NOT NULL,
        document TEXT NOT NULL,
        niveau_signature TEXT NOT NULL,
        horodatage TEXT NOT NULL,
        FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs (id_utilisateur)
      )
    ''');
    
    await db.execute('''
  CREATE TABLE user_ibox (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    ibox_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES utilisateurs (id_utilisateur),
    FOREIGN KEY (ibox_id) REFERENCES ibox (id_ibox)
  )
''');

    await _initializeDefaultData(db);
  }

Future<void> _initializeDefaultData(Database db) async {
  // Comptes utilisateurs par défaut
  await db.insert('utilisateurs', {
    'nom': 'Admin',
    'prenom': 'System',
    'adresse_email': 'admin@dipost.cm',
    'mot_de_passe': 'admin123', // À changer en production
    'telephone': '237690000001',
    'role': 'admin',
    'created_at': DateTime.now().toIso8601String(),
  });

  await db.insert('utilisateurs', {
    'nom': 'Opérateur',
    'prenom': 'Principal',
    'adresse_email': 'operateur@dipost.cm',
    'mot_de_passe': 'operateur123',
    'telephone': '237690000002',
    'role': 'operateur',
    'created_at': DateTime.now().toIso8601String(),
  });

  await db.insert('utilisateurs', {
    'nom': 'Livreur',
    'prenom': 'Principal',
    'adresse_email': 'livreur@dipost.cm',
    'mot_de_passe': 'livreur123',
    'telephone': '237690000003',
    'role': 'livreur',
    'created_at': DateTime.now().toIso8601String(),
  });
  await db.insert('utilisateurs', {
    'nom': 'user',
    'prenom': '237',
    'adresse_email': 'user@gmail.com',
    'mot_de_passe': '123456',
    'telephone': '65559874',
    'role': 'client',
    'created_at': DateTime.now().toIso8601String(),
  });

   await db.insert('utilisateurs', {
    'nom': 'Client',
      'prenom': 'Standard',
      'adresse_email': 'client2@dipost.cm',
      'mot_de_passe': 'client123',
      'telephone': '237692222222',
      'role': 'client',
    'created_at': DateTime.now().toIso8601String(),
  });

  await db.insert('utilisateurs', {
    'nom': 'Client',
      'prenom': 'Premium',
      'adresse_email': 'client1@dipost.cm',
      'mot_de_passe': 'client123',
      'telephone': '237691111111',
      'role': 'client',
    'created_at': DateTime.now().toIso8601String(),
  });

  // Ajout de 10 iBox
  final iboxes = [
    {'adresse': 'Yaoundé, Centre Ville', 'capacite': 20, 'statut': 'Disponible'},
    {'adresse': 'Douala, Bonanjo', 'capacite': 15, 'statut': 'Disponible'},
    {'adresse': 'Bafoussam, Centre', 'capacite': 10, 'statut': 'Occupée'},
    {'adresse': 'Garoua, Marché Central', 'capacite': 12, 'statut': 'Disponible'},
    {'adresse': 'Bamenda, Up Station', 'capacite': 8, 'statut': 'En maintenance'},
    {'adresse': 'Maroua, Pont Vert', 'capacite': 15, 'statut': 'Disponible'},
    {'adresse': 'Ngaoundéré, Carrefour Sobel', 'capacite': 10, 'statut': 'Occupée'},
    {'adresse': 'Limbe, Down Beach', 'capacite': 5, 'statut': 'Disponible'},
    {'adresse': 'Kribi, Port', 'capacite': 8, 'statut': 'Disponible'},
    {'adresse': 'Ebolowa, Marché Municipal', 'capacite': 10, 'statut': 'Hors service'},
  ];

  for (var ibox in iboxes) {
    await db.insert('ibox', {
      ...ibox,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  await assignIBoxToOperator(2, 1, db); // Opérateur gère iBox 1
  await assignIBoxToOperator(2, 2, db); // Opérateur gère iBox 2

   // Ajout de colis de test
  final colisList = [
    {
      'id_ibox': 1,
      'id_destinataire': 4, // Client
      'id_expediteur': 1, // Admin
      'contenu': 'Documents importants',
      'statut': 'Enregistré',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'id_ibox': 2,
      'id_destinataire': 4, // Client
      'id_expediteur': 3, // Livreur
      'contenu': 'Colis fragile',
      'statut': 'En transit',
      'created_at': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
    {
      'id_ibox': 3,
      'id_destinataire': 3, // Client
      'id_expediteur': 1, // Admin
      'contenu': 'Échantillons produits',
      'statut': 'Livré',
      'created_at': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      'updated_at': DateTime.now().subtract(Duration(hours: 6)).toIso8601String(),
    },
    {
      'id_ibox': null, // Pas encore assigné à une iBox
      'id_destinataire': 5, // Client
      'id_expediteur': 1, // Admin
      'contenu': 'Commande e-commerce',
      'statut': 'En préparation',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
  ];

  for (var colis in colisList) {
    await db.insert('colis', colis);
  }

  // Ajout de livraisons de test
  final livraisons = [
    {
      'id_colis': 3,
      'id_livreur': 3,
      'date_livraison': DateTime.now().subtract(Duration(hours: 6)).toIso8601String(),
      'statut_livraison': 'Livré',
    },
    {
      'id_colis': 2,
      'id_livreur': 3,
      'date_livraison': DateTime.now().toIso8601String(),
      'statut_livraison': 'En cours',
    },
  ];

  for (var livraison in livraisons) {
    await db.insert('livraisons', livraison);
  }
}

Future<void> assignIBoxToOperator(int userId, int iboxId, Database db) async {
  await db.insert('user_ibox', {
    'user_id': userId,
    'ibox_id': iboxId,
  });
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(table, data);
  }
}
  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<dynamic>? whereArgs}) async {
    final db = await instance.database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> deleteDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'dipost.db');
  await databaseFactory.deleteDatabase(path);
}

Future<void> recreateDatabase() async {
  await deleteDatabase();
  final db = await _initDB('dipost.db');
  await db.close();
}

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

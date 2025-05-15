import 'package:dipost_app/models/document.dart';
import 'package:dipost_app/models/signature.dart';
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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        colis_id INTEGER NOT NULL,
        livreur_id INTEGER DEFAULT 0,
        statut TEXT DEFAULT 'En attente',
        date_demande TEXT,
        date_livraison TEXT,
        date_modification TEXT,
        FOREIGN KEY (colis_id) REFERENCES colis (id_colis),
        FOREIGN KEY (livreur_id) REFERENCES utilisateurs (id_utilisateur)
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
  CREATE TABLE user_ibox (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    ibox_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES utilisateurs (id_utilisateur),
    FOREIGN KEY (ibox_id) REFERENCES ibox (id_ibox)
  )
''');

    await db.execute('''
  CREATE TABLE historique_livraisons (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      livraison_id INTEGER NOT NULL,
      action TEXT NOT NULL, -- "Scan", "Livré", etc.
      date_action TEXT NOT NULL,
      user_id INTEGER, -- Livreur ou système
      FOREIGN KEY (livraison_id) REFERENCES livraisons(id)
    );
''');

    await db.execute('''
  CREATE TABLE signatures (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_utilisateur INTEGER NOT NULL,
    document_path TEXT NOT NULL,
    document_type TEXT NOT NULL,
    signature_data TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs (id_utilisateur)
  )
''');

    await db.execute('''
  CREATE TABLE documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    file_path TEXT NOT NULL,
    type TEXT NOT NULL,
    upload_date TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES utilisateurs (id_utilisateur)
  )
''');

    await _initializeDefaultData(db);
  }

  Future<void> _initializeDefaultData(Database db) async {
    // 1. Création des utilisateurs avec des données cohérentes
    final users = [
      // Administrateur
      {
        'nom': 'VOLDIGOAD',
        'prenom': 'BYRON',
        'adresse_email': 'admin@dipost.cm',
        'mot_de_passe': 'admin123',
        'telephone': '237690000001',
        'role': 'admin',
        'created_at': _formatDate(DateTime.now()),
      },
      // Opérateurs
      {
        'nom': 'Tempest',
        'prenom': 'Rimuru',
        'adresse_email': 'rimuru@dipost.cm',
        'mot_de_passe': '123456',
        'telephone': '237690000011',
        'role': 'operateur',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'nom': 'Milim',
        'prenom': 'Nava',
        'adresse_email': 'milim@dipost.cm',
        'mot_de_passe': '123456',
        'telephone': '237690000012',
        'role': 'operateur',
        'created_at': _formatDate(DateTime.now()),
      },
      // Livreurs
      {
        'nom': 'Shion',
        'prenom': 'Ogre',
        'adresse_email': 'shion@dipost.cm',
        'mot_de_passe': '123456',
        'telephone': '237690000021',
        'role': 'livreur',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'nom': 'Benimaru',
        'prenom': 'Flame',
        'adresse_email': 'benimaru@dipost.cm',
        'mot_de_passe': '123456',
        'telephone': '237690000022',
        'role': 'livreur',
        'created_at': _formatDate(DateTime.now()),
      },
      // Clients
      {
        'nom': 'Tempest',
        'prenom': 'Shuna',
        'adresse_email': 'shuna@dipost.cm',
        'mot_de_passe': '123456',
        'telephone': '237691111112',
        'role': 'client',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'nom': 'Tempest',
        'prenom': 'Gobta',
        'adresse_email': 'gobta@dipost.cm',
        'mot_de_passe': '123456',
        'telephone': '237691111113',
        'role': 'client',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'nom': 'Tempest',
        'prenom': 'Ranga',
        'adresse_email': 'ranga@dipost.cm',
        'mot_de_passe': '123456',
        'telephone': '237691111114',
        'role': 'client',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'nom': 'Demon',
        'prenom': 'Diablo',
        'adresse_email': 'diablo@dipost.cm',
        'mot_de_passe': '123456',
        'telephone': '237691111115',
        'role': 'client',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'nom': 'Dragon',
        'prenom': 'Veldora',
        'adresse_email': 'veldora@dipost.cm',
        'mot_de_passe': '123456',
        'telephone': '237692222222',
        'role': 'client',
        'created_at': _formatDate(DateTime.now()),
      },
    ];

    // Insertion des utilisateurs et récupération des IDs
    final userIds = <int>[];
    for (var user in users) {
      final id = await db.insert('utilisateurs', user);
      userIds.add(id);
    }

    // 2. Création des iBox avec des données réalistes
    final iboxes = [
      {
        'adresse': 'Tempest, Quartier Central, Rue des Ogres',
        'capacite': 20,
        'statut': 'Disponible',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'adresse': 'Tempest, Forêt des Loups, Allée Principale',
        'capacite': 15,
        'statut': 'Disponible',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'adresse': 'Tempest, Montagnes des Dragons, Chemin Rocheux',
        'capacite': 10,
        'statut': 'Occupée',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'adresse': 'Tempest, Vallée des Démons, Sentier Caché',
        'capacite': 12,
        'statut': 'Disponible',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'adresse': 'Tempest, Lac des Esprits, Quai Principal',
        'capacite': 25,
        'statut': 'Disponible',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'adresse': 'Tempest, Tour des Sages, Hall Principal',
        'capacite': 18,
        'statut': 'Occupée',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'adresse': 'Tempest, Plaine des Batailles, Campement Nord',
        'capacite': 30,
        'statut': 'Disponible',
        'created_at': _formatDate(DateTime.now()),
      },
      {
        'adresse': 'Tempest, Sanctuaire des Dragons, Entrée Sud',
        'capacite': 20,
        'statut': 'Occupée',
        'created_at': _formatDate(DateTime.now()),
      },
    ];

    // Insertion des iBox et récupération des IDs
    final iboxIds = <int>[];
    for (var ibox in iboxes) {
      final id = await db.insert('ibox', ibox);
      iboxIds.add(id);
    }

    // 3. Assignation des iBox aux opérateurs
    await _assignIBoxToOperator(
      userIds[1],
      iboxIds[0],
      db,
    ); // Marc gère Yaoundé
    await _assignIBoxToOperator(
      userIds[2],
      iboxIds[1],
      db,
    ); // Sophie gère Douala

    // 4. Création des colis avec des relations cohérentes
    final colisList = [
      {
        'id_ibox': iboxIds[0], // Quartier Central
        'id_destinataire': userIds[5], // Shuna
        'id_expediteur': userIds[6], // Gobta
        'contenu': 'Cristaux Magiques',
        'statut': 'En attente',
        'created_at': _formatDate(DateTime.now().subtract(Duration(days: 2))),
        'updated_at': _formatDate(DateTime.now()),
      },
      {
        'id_ibox': iboxIds[1], // Forêt des Loups
        'id_destinataire': userIds[6], // Gobta
        'id_expediteur': userIds[5], // Shuna
        'contenu': 'Épées Enchantées',
        'statut': 'En cours',
        'created_at': _formatDate(DateTime.now().subtract(Duration(days: 1))),
        'updated_at': _formatDate(DateTime.now()),
      },
      {
        'id_ibox': iboxIds[2], // Montagnes des Dragons
        'id_destinataire': userIds[5], // Shuna
        'id_expediteur': userIds[1], // Rimuru
        'contenu': 'Artefacts Ancestraux',
        'statut': 'Livré',
        'created_at': _formatDate(DateTime.now().subtract(Duration(days: 3))),
        'updated_at': _formatDate(DateTime.now().subtract(Duration(days: 1))),
      },
      {
        'id_ibox': iboxIds[3], // Vallée des Démons
        'id_destinataire': userIds[7], // Diablo
        'id_expediteur': userIds[8], // Veldora
        'contenu': 'Manuscrits Anciens',
        'statut': 'En attente',
        'created_at': _formatDate(DateTime.now().subtract(Duration(days: 4))),
        'updated_at': _formatDate(DateTime.now()),
      },
      {
        'id_ibox': iboxIds[4], // Lac des Esprits
        'id_destinataire': userIds[8], // Veldora
        'id_expediteur': userIds[7], // Diablo
        'contenu': 'Élixirs Rares',
        'statut': 'En cours',
        'created_at': _formatDate(DateTime.now().subtract(Duration(days: 2))),
        'updated_at': _formatDate(DateTime.now()),
      },
      {
        'id_ibox': iboxIds[5], // Tour des Sages
        'id_destinataire': userIds[5], // Shuna
        'id_expediteur': userIds[6], // Gobta
        'contenu': 'Parchemins Magiques',
        'statut': 'Livré',
        'created_at': _formatDate(DateTime.now().subtract(Duration(days: 6))),
        'updated_at': _formatDate(DateTime.now().subtract(Duration(days: 3))),
      },
      {
        'id_ibox': iboxIds[6], // Plaine des Batailles
        'id_destinataire': userIds[6], // Gobta
        'id_expediteur': userIds[5], // Shuna
        'contenu': 'Armes Enchantées',
        'statut': 'En attente',
        'created_at': _formatDate(DateTime.now().subtract(Duration(days: 1))),
        'updated_at': _formatDate(DateTime.now()),
      },
    ];

    // Insertion des colis et récupération des IDs
    final colisIds = <int>[];
    for (var colis in colisList) {
      final id = await db.insert('colis', colis);
      colisIds.add(id);
    }

    // 5. Création des livraisons avec des états cohérents
    final livraisons = [
      // Livraison terminée
      {
        'colis_id': colisIds[2], // Artefacts Ancestraux
        'livreur_id': userIds[3], // Shion
        'statut': 'Livré',
        'date_demande': _formatDate(DateTime.now().subtract(Duration(days: 3))),
        'date_livraison': _formatDate(
          DateTime.now().subtract(Duration(days: 1)),
        ),
      },
      // Livraison en cours
      {
        'colis_id': colisIds[1], // Épées Enchantées
        'livreur_id': userIds[4], // Benimaru
        'statut': 'En cours',
        'date_demande': _formatDate(
          DateTime.now().subtract(Duration(hours: 5)),
        ),
      },
      // Livraison en attente
      {
        'colis_id': colisIds[0], // Cristaux Magiques
        'statut': 'En attente',
        'date_demande': _formatDate(
          DateTime.now().subtract(Duration(hours: 2)),
        ),
      },
      {
        'colis_id': colisIds[3], // Manuscrits Anciens
        'livreur_id': userIds[3], // Shion
        'statut': 'En attente',
        'date_demande': _formatDate(DateTime.now().subtract(Duration(days: 4))),
      },
      {
        'colis_id': colisIds[4], // Élixirs Rares
        'livreur_id': userIds[4], // Benimaru
        'statut': 'En cours',
        'date_demande': _formatDate(DateTime.now().subtract(Duration(days: 2))),
      },
      {
        'colis_id': colisIds[5], // Parchemins Magiques
        'livreur_id': userIds[3], // Shion
        'statut': 'Livré',
        'date_demande': _formatDate(DateTime.now().subtract(Duration(days: 6))),
        'date_livraison': _formatDate(
          DateTime.now().subtract(Duration(days: 3)),
        ),
      },
      {
        'colis_id': colisIds[6], // Armes Enchantées
        'livreur_id': userIds[4], // Benimaru
        'statut': 'En attente',
        'date_demande': _formatDate(DateTime.now().subtract(Duration(days: 1))),
      },
    ];

    for (var livraison in livraisons) {
      await db.insert('livraisons', livraison);
    }

    // 6. Création de données historiques
    await db.insert('historique_livraisons', {
      'livraison_id': 1,
      'action': 'Scan départ',
      'date_action': _formatDate(DateTime.now().subtract(Duration(days: 3))),
      'user_id': userIds[1], // Opérateur Marc
    });

    await db.insert('historique_livraisons', {
      'livraison_id': 1,
      'action': 'Livré',
      'date_action': _formatDate(DateTime.now().subtract(Duration(days: 1))),
      'user_id': userIds[3], // Livreur Jean
    });

    await db.insert('historique_livraisons', {
      'livraison_id': 2,
      'action': 'Scan départ',
      'date_action': _formatDate(DateTime.now().subtract(Duration(days: 2))),
      'user_id': userIds[4], // Benimaru
    });

    await db.insert('historique_livraisons', {
      'livraison_id': 3,
      'action': 'Scan départ',
      'date_action': _formatDate(DateTime.now().subtract(Duration(days: 6))),
      'user_id': userIds[3], // Shion
    });

    await db.insert('historique_livraisons', {
      'livraison_id': 3,
      'action': 'Livré',
      'date_action': _formatDate(DateTime.now().subtract(Duration(days: 3))),
      'user_id': userIds[3], // Shion
    });

    await db.insert('historique_livraisons', {
      'livraison_id': 4,
      'action': 'Scan départ',
      'date_action': _formatDate(DateTime.now().subtract(Duration(days: 1))),
      'user_id': userIds[4], // Benimaru
    });
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String();
  }

  Future<void> _assignIBoxToOperator(
    int userId,
    int iboxId,
    Database db,
  ) async {
    await db.insert('user_ibox', {'user_id': userId, 'ibox_id': iboxId});
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await instance.database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
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

  Future<Map<String, dynamic>> getDeliveryStats() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: 7)).toIso8601String();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    final weekly = await db.rawQuery(
      '''
    SELECT 
      COUNT(*) as total,
      SUM(CASE WHEN statut = 'Livré' THEN 1 ELSE 0 END) as delivered,
      SUM(CASE WHEN statut = 'En cours' THEN 1 ELSE 0 END) as in_progress,
      SUM(CASE WHEN statut = 'En attente' THEN 1 ELSE 0 END) as pending
    FROM livraisons
    WHERE date_demande >= ?
  ''',
      [startOfWeek],
    );

    final monthly = await db.rawQuery(
      '''
    SELECT 
      COUNT(*) as total,
      SUM(CASE WHEN statut = 'Livré' THEN 1 ELSE 0 END) as delivered
    FROM livraisons
    WHERE date_demande >= ?
  ''',
      [startOfMonth],
    );

    return {'week': weekly.first, 'month': monthly.first};
  }

  Future<List<Map<String, dynamic>>> getTopUsers() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT 
      u.id_utilisateur, 
      u.prenom, 
      u.nom, 
      u.role,
      u.telephone,
      u.adresse_email,
      COUNT(DISTINCT l.id) as total_livraisons,
      SUM(CASE WHEN l.statut = 'Livré' THEN 1 ELSE 0 END) as deliveries_completed,
      (SELECT COUNT(*) FROM colis 
       WHERE id_expediteur = u.id_utilisateur OR id_destinataire = u.id_utilisateur) as colis_geres,
      (SELECT COUNT(*) FROM user_ibox WHERE user_id = u.id_utilisateur) as ibox_managed
    FROM utilisateurs u
    LEFT JOIN livraisons l ON u.id_utilisateur = l.livreur_id
    WHERE u.role IN ('operateur', 'livreur')
    GROUP BY u.id_utilisateur
    ORDER BY 
      CASE 
        WHEN u.role = 'livreur' THEN deliveries_completed
        WHEN u.role = 'operateur' THEN colis_geres + ibox_managed
        ELSE 0
      END DESC,
      u.nom ASC, u.prenom ASC
    LIMIT 5
  ''');
  }

  Future<Map<String, dynamic>> getAvgDeliveryTime() async {
    final db = await database;
    return await db
        .rawQuery('''
    SELECT 
      AVG(julianday(date_livraison) - julianday(date_demande)) as avg_days
    FROM livraisons
    WHERE statut = 'Livré' AND date_livraison IS NOT NULL
  ''')
        .then((r) => r.first);
  }

  Future<List<Map<String, dynamic>>> getIBoxStats() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT statut, COUNT(*) as count 
    FROM ibox 
    GROUP BY statut
  ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> insertSignature(MySignature signature) async {
    final db = await database;
    return await db.insert('signatures', signature.toMap());
  }

  Future<List<MySignature>> getSignaturesByUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'signatures',
      where: 'id_utilisateur = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return MySignature.fromMap(maps[i]);
    });
  }

  Future<MySignature?> getSignatureById(int id) async {
    final db = await database;
    final maps = await db.query('signatures', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return MySignature.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteSignature(int id) async {
    final db = await database;
    return await db.delete('signatures', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertDocument(Document document) async {
    final db = await database;
    return await db.insert('documents', document.toMap());
  }

  // Dans DatabaseHelper
  Future<List<Document>> getDocumentsByUser(int? userId) async {
    final db = await database;
    final where = userId != null ? 'user_id = ?' : null;
    final whereArgs = userId != null ? [userId] : null;

    final maps = await db.query(
      'documents',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'upload_date DESC',
    );
    return maps.map((map) => Document.fromMap(map)).toList();
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }
}

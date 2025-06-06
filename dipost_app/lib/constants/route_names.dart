class RouteNames {
  // Authentification
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  
  // Main
  static const String dashboard = '/dashboard';
  
  // iBox
  static const String iboxList = '/ibox';
  static const String iboxDetail = '/ibox/detail';
  static const String iboxCreate = '/ibox/create';
  
  // Colis
  static const String colisList = '/colis';
  static const String colisDetail = '/colis/detail';
  static const String addColis = '/add-colis';

  // Livraisons
  static const String livraisonList = '/livraison';
  static const String livraisonDetail = '/livraison/detail';
  static const String livraisonListUser = '/livraisons-user';
  static const String livraisonDetailUser = '/livraison/detail';
  static const String livraisonScan = '/livraison-scan';
  static const String livraisonListLivreur = '/livraison-livreur';
  static const String livraisonManagement = '/livraison-management';
  
  // Signatures
  static const String documentUpload = '/document/upload';
  static const String documentList = '/document/list';
  static const String signatureCapture = '/signature/capture';
  static const String signatureList = '/signature/list';

  
  // Admin
  static const String userManagement = '/admin/users';
}
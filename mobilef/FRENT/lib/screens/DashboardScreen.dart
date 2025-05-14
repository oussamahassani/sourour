import 'package:flutter/material.dart';
import 'package:frent/screens/bonCommandeVente.dart';
import '../models/article.dart';
import '../screens/fournisseur/fournisseur.dart';
import 'achat_direct.dart';
import 'bonCommandeAchat.dart';
import 'bonLivraison.dart';
import 'bonReception.dart';
import 'bonSortie.dart';
import 'bonTransfert.dart';
import 'client.dart';
import 'article.dart';
import 'devis.dart';
import 'factureAchat.dart';
import 'factureVente.dart';
import 'paiementVente.dart';
import 'employe.dart';
import '../services/client_service.dart';
import '../models/Dashbord.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color primaryColor = Color(0xFF159E97);
  final Color secondaryColor = Color(0xFF0D7E78);
  final Color backgroundColor = Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF2D3748);
  final Color textSecondaryColor = Color(0xFF718096);

  get client => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Tableau de Bord',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(icon: Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
                  child: Text(
                    'Aperçu général',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                _buildRowWithTwoCards(
                  'Achat',
                  'Analyse des achats',
                  Icons.shopping_cart_outlined,
                  'Vente',
                  'Analyse des ventes',
                  Icons.store_outlined,
                ),
                SizedBox(height: 16),
                _buildRowWithTwoCards(
                  'Statut Financier',
                  'État financier actuel',
                  Icons.account_balance_outlined,
                  'Alertes Stock',
                  'Articles en rupture',
                  Icons.warning_amber_outlined,
                ),
                SizedBox(height: 16),
                _buildRowWithTwoCards(
                  'TVA sur Achat et Vente',
                  'Total TVA payée et collectée',
                  Icons.receipt_long_outlined,
                  'Encaissement en Cours',
                  'Paiements en attente',
                  Icons.payments_outlined,
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
                  child: Text(
                    'Activité récente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                _buildActivityCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchDashbordData();
  }

  Dashbord dummyData = Dashbord(
    totalPrixTTC: "0",
    totalTTcVente: "0",
    sumTva: "0",
  );
  Future<void> fetchDashbordData() async {
    final dataDash =
        await ClientService.fetchDashbordData(); // Doit renvoyer un Future<List<Employee>>
    setState(() {
      dummyData = dataDash;
    });
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.account_circle,
                      size: 50,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Menu Principal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gestion d\'entreprise',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildExpansionTile('Achat', Icons.shopping_cart_outlined, [
              _buildDrawerItem('Achat Direct', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AchatDirectMobileScreen(),
                  ),
                );
              }),
              _buildDrawerItem('Bon de Commande', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BonDeCommandeScreen(),
                  ),
                );
              }),
              _buildDrawerItem('Bon de Reception', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BonDeReceptionScreen(),
                  ),
                );
              }),
            
              _buildDrawerItem('Paiement', () {}),
            ]),
            _buildExpansionTile('Vente', Icons.store_outlined, [
              _buildDrawerItem('Devis', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DevisMobileScreen()),
                );
              }),
              _buildDrawerItem('Bon de Commande', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BonCommandeMobileScreen(),
                  ),
                );
              }),
              _buildDrawerItem('Bon de Livraison', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BonLivraisonMobileScreen(),
                  ),
                );
              }),
              _buildDrawerItem('Bon de Sortie', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BonSortiePage()),
                );
              }),
              _buildDrawerItem('Bon de Transfert', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BonTransfertPage()),
                );
              }),
            
              _buildDrawerItem('Paiement', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormulaireVenteScreen(),
                  ),
                );
              }),
            ]),
             _buildExpansionTile('Facturation', Icons.people_outline, [
              _buildDrawerItem('Facture Achat', () {
               Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FactureHistoriquePage(
     
    ),
  ),
);
              }),
              _buildDrawerItem('Facture Vente', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FactureHistoriquePage1()),
                );
              }),
            ]),
            _buildExpansionTile('Contact', Icons.people_outline, [
              _buildDrawerItem('Clients', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Client(clientData: {}, clientId: null),
                  ),
                );
              }),
              _buildDrawerItem('Fournisseurs', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FournisseurScreen(fournisseurData: {}),
                  ),
                );
              }),
            ]),
           _buildExpansionTile(
              'Finance',
              Icons.account_balance_outlined,
              [
                _buildDrawerItem('Statut Financier', () {Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FinanceApp()),
                  );}),
                _buildDrawerItem('Comptes', () {Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ComptaApp()),
                  );}),
              ],
            ),
            _buildExpansionTile('Stock', Icons.inventory_2_outlined, [
              _buildDrawerItem('Articles', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ArticleFormScreen(
                          article:
                              null, // Pass an existing article if editing, or null for new
                          onSave: (newArticle) async {},
                        ),
                  ),
                );
              }),
             
            ]),
            _buildExpansionTile(
              'Technique',
              Icons.build_outlined,
              [
                _buildDrawerItem('Intervention', () {Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InterventionApp()),
                  );}),
                _buildDrawerItem('Rapport d\'Intervention', () {Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InterventionReportForm()),
                  );}),
                _buildDrawerItem('planning', () {Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InterventionListApp()),
                  );}),
              ],
            ),
            _buildExpansionTile(
              'Ressources Humaines',
              Icons.people_alt_outlined,
              [
                _buildDrawerItem('Création Compte Employé', () {
                  Navigator.pop(context); // Close the drawer first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeManagementApp(),
                    ),
                  );
                }),
               
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    String title,
    VoidCallback onTap, {
    IconData? icon,
    Color? color,
  }) {
    return ListTile(
      leading:
          icon != null ? Icon(icon, color: color ?? textSecondaryColor) : null,
      title: Text(
        title,
        style: TextStyle(
          color: color ?? textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity(horizontal: 0, vertical: -1),
    );
  }

  Widget _buildExpansionTile(String title, IconData icon, List<Widget> items) {
    return ExpansionTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: textColor,
        ),
      ),
      childrenPadding: EdgeInsets.only(left: 16),
      children: items,
    );
  }

  Widget _buildRowWithTwoCards(
    String title1,
    String subtitle1,
    IconData icon1,
    String title2,
    String subtitle2,
    IconData icon2,
  ) {
    return Row(
      children: [
        Expanded(child: _buildDashboardCard(title1, subtitle1, icon1)),
        SizedBox(width: 16),
        Expanded(child: _buildDashboardCard(title2, subtitle2, icon2)),
      ],
    );
  }

  Widget _buildDashboardCard(String title, String subtitle, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: textSecondaryColor),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: textSecondaryColor, fontSize: 14),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Détails',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.arrow_forward, size: 16, color: primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions récentes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 16),
            _buildActivityItem(
              'Facture #2305',
              'Client: Entreprise ABC',
              '5 200,00 €',
              Icons.arrow_upward,
              Colors.green,
              'Il y a 2 heures',
            ),
            Divider(),
            _buildActivityItem(
              'Achat #1093',
              'Fournisseur: XYZ Distribution',
              '1 800,00 €',
              Icons.arrow_downward,
              Colors.red.shade700,
              'Il y a 5 heures',
            ),
            Divider(),
            _buildActivityItem(
              'Paiement #8732',
              'Client: Martin SA',
              '3 450,00 €',
              Icons.arrow_upward,
              Colors.green,
              'Hier, 14:30',
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Voir toutes les transactions',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String amount,
    IconData icon,
    Color iconColor,
    String time,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: textSecondaryColor),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(fontWeight: FontWeight.bold, color: iconColor),
              ),
              SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: textSecondaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

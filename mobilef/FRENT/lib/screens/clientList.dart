import 'package:flutter/material.dart';
import 'package:frent/screens/client.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00796B);
  static const Color secondaryColor = Color(0xFF26A69A);
  static const Color accentColor = Color(0xFF004D40);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color darkGrey = Color(0xFF757575);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  static const cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    )
  ];
}

class ClientList extends StatefulWidget {
  const ClientList({super.key});

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ClientProvider>(context, listen: false).loadClients());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Clients',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: () => Provider.of<ClientProvider>(context, listen: false).loadClients(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isSmallScreen),
          Expanded(child: _buildClientList(isSmallScreen)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Client(clientData: {}, clientId: null),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(bool isSmallScreen) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un client...',
          hintStyle: TextStyle(color: AppTheme.darkGrey.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: AppTheme.darkGrey),
          suffixIcon: _searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.darkGrey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          contentPadding:  EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppTheme.lightGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppTheme.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildClientList(bool isSmallScreen) {
    return Consumer<ClientProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                Text('Chargement des clients...',
                    style: TextStyle(color: AppTheme.darkGrey)),
              ],
            ),
          );
        }
        
        if (provider.clients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: AppTheme.darkGrey),
                const SizedBox(height: 16),
                Text('Aucun client trouvé',
                  style: TextStyle(fontSize: 18, color: AppTheme.darkGrey)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un client'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Client(clientData: {}, clientId: null),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        final filteredClients = provider.clients.where((client) {
          final name = client['type'] == 'Moral' 
              ? (client['entreprise']?.toString().toLowerCase() ?? '')
              : '${client['prenom']?.toString().toLowerCase() ?? ''} ${client['nom']?.toString().toLowerCase() ?? ''}'.trim();
          
          return name.contains(_searchQuery) || 
                 (client['email']?.toString().toLowerCase() ?? '').contains(_searchQuery) || 
                 (client['telephone']?.toString().toLowerCase() ?? '').contains(_searchQuery);
        }).toList();

        if (filteredClients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: AppTheme.darkGrey),
                const SizedBox(height: 16),
                Text('Aucun résultat pour "$_searchQuery"',
                  style: const TextStyle(fontSize: 18, color: AppTheme.darkGrey)),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Effacer la recherche'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () => provider.loadClients(),
          child: ListView.builder(
            itemCount: filteredClients.length,
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemBuilder: (context, index) {
              final client = filteredClients[index];
              final name = client['type'] == 'Moral' 
                  ? client['entreprise']?.toString() ?? 'Entreprise'
                  : '${client['prenom']?.toString() ?? ''} ${client['nom']?.toString() ?? ''}'.trim();

              IconData typeIcon = client['type'] == 'Moral' 
                  ? Icons.business
                  : Icons.person;

              return Card(
                margin:  EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.secondaryColor,
                    child: Icon(typeIcon, color: Colors.white),
                  ),
                  title: Text(name, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: AppTheme.darkGrey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              client['email']?.toString() ?? 'Pas d\'email',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 14, color: AppTheme.darkGrey),
                          const SizedBox(width: 6),
                          Text(
                            client['telephone']?.toString() ?? 'Pas de téléphone',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: isSmallScreen 
                      ? IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showClientOptions(context, client),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined, size: 22, color: AppTheme.darkGrey),
                              tooltip: 'Voir détails',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClientDetailScreen(client: client)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 22, color: Colors.blue),
                              tooltip: 'Modifier',
                              onPressed: () => _navigateToClientEdit(context, client),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 22, color: AppTheme.errorColor),
                              tooltip: 'Supprimer',
                              onPressed: () => _confirmDelete(context, Provider.of<ClientProvider>(context, listen: false), client),
                            ),
                          ],
                        ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailScreen(client: client)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToClientEdit(BuildContext context, Map<String, dynamic> client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Client(
          clientData: client,
          clientId: client['idCL']?.toString(), onSave: (newClient) {  }, // Conversion en string
        ),
      ),
    );
  }

  void _showClientOptions(BuildContext context, Map<String, dynamic> client) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin:  EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.visibility_outlined, color: AppTheme.primaryColor),
              title: const Text('Voir détails'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientDetailScreen(client: client)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Colors.blue),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToClientEdit(context, client);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              title: const Text('Supprimer'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, Provider.of<ClientProvider>(context, listen: false), client);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ClientProvider provider, Map<String, dynamic> client) async {
    final clientName = client['type'] == 'Moral' 
        ? client['entreprise']?.toString() ?? 'Cette entreprise'
        : '${client['prenom']?.toString() ?? ''} ${client['nom']?.toString() ?? ''}'.trim();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer $clientName ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final clientId = client['idCL'];
        final idToDelete = clientId is int ? clientId.toString() : clientId?.toString();
        
        await provider.deleteClient(idToDelete!);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$clientName a été supprimé'),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }
}

class ClientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> client;
  
  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final name = client['type'] == 'Moral' 
        ? client['entreprise']?.toString() ?? 'Entreprise'
        : '${client['prenom']?.toString() ?? ''} ${client['nom']?.toString() ?? ''}'.trim();
    
    final IconData clientTypeIcon = client['type'] == 'Moral' 
        ? Icons.business
        : Icons.person;
    
    final Color cardBackgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Détails client'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Client(
                  clientData: client,
                  clientId: client['idCL']?.toString(), onSave: (newClient) {  }, // Conversion en string
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: isSmallScreen ? 16 : 24),
        child: Column(
          children: [
            Card(
              elevation: 3,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: isSmallScreen ? 40 : 50,
                      backgroundColor: AppTheme.secondaryColor,
                      child: Icon(
                        clientTypeIcon,
                        size: isSmallScreen ? 32 : 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name, 
                      style: const TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        client['type']?.toString() ?? 'Client',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionCard(
              context,
              "Coordonnées",
              Icons.contact_mail,
              [
                _buildDetailItem(Icons.email, "Email", client['email']?.toString()),
                _buildDetailItem(Icons.phone, "Téléphone", client['telephone']?.toString()),
                if (client['adresse'] != null)
                  _buildDetailItem(Icons.location_on, "Adresse", client['adresse'].toString()),
              ],
              cardBackgroundColor,
            ),
            
            const SizedBox(height: 16),
            
            if (client['type'] == 'Moral')
              _buildSectionCard(
                context,
                "Informations entreprise",
                Icons.business_center,
                [
                  if (client['siren'] != null)
                    _buildDetailItem(Icons.confirmation_number, "SIREN", client['siren'].toString()),
                  if (client['activite'] != null)
                    _buildDetailItem(Icons.category, "Activité", client['activite'].toString()),
                  if (client['dateCreation'] != null)
                    _buildDetailItem(Icons.calendar_today, "Date de création", client['dateCreation'].toString()),
                ],
                cardBackgroundColor,
              )
            else if (client['type'] == 'Physique')
              _buildSectionCard(
                context,
                "Informations personnelles",
                Icons.person_outline,
                [
                  if (client['profession'] != null)
                    _buildDetailItem(Icons.work, "Profession", client['profession'].toString()),
                  if (client['dateNaissance'] != null)
                    _buildDetailItem(Icons.cake, "Date de naissance", client['dateNaissance'].toString()),
                ],
                cardBackgroundColor,
              ),
              
            if (client['notes'] != null && client['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                "Notes",
                Icons.note,
                [
                  _buildDetailItem(Icons.comment, "Commentaires", client['notes'].toString()),
                ],
                cardBackgroundColor,
              ),
            ],
            
            const SizedBox(height: 16),
            _buildAdditionalInfoCard(context, client),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Client(
                        clientData: client,
                        clientId: client['idCL']?.toString(), // Conversion en string
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                  label: const Text('Supprimer', style: TextStyle(color: AppTheme.errorColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.errorColor),
                    padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => _confirmDelete(context, client),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Map<String, dynamic> client) async {
    final clientName = client['type'] == 'Moral' 
        ? client['entreprise']?.toString() ?? 'Cette entreprise'
        : '${client['prenom']?.toString() ?? ''} ${client['nom']?.toString() ?? ''}'.trim();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer $clientName ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final clientId = client['idCL'];
        final idToDelete = clientId is int ? clientId.toString() : clientId?.toString();
        
        await Provider.of<ClientProvider>(context, listen: false).deleteClient(idToDelete!);
        
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$clientName a été supprimé'),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, List<Widget> children, Color backgroundColor) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.darkGrey, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.darkGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value?.isNotEmpty == true ? value! : 'Non renseigné',
                  style: TextStyle(
                    fontSize: 16,
                    color: value?.isNotEmpty == true ? Colors.black : AppTheme.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context, Map<String, dynamic> client) {
    final displayedFields = [
      'idCL', 'type', 'nom', 'prenom', 'entreprise', 'email', 'telephone', 
      'adresse', 'siren', 'profession', 'dateNaissance', 'activite', 
      'dateCreation', 'notes'
    ];
    
    final additionalFields = client.keys
        .where((key) => !displayedFields.contains(key) && client[key] != null)
        .toList();
    
    if (additionalFields.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.more_horiz, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  "Informations supplémentaires",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...additionalFields.map((key) => _buildDetailItem(
              Icons.info_outline,
              key,
              client[key]?.toString()
            )).toList(),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/fournisseur.dart';
import '../../providers/fournisseur_provider.dart';
import 'fournisseur.dart';

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

class FournisseurList extends StatefulWidget {
  const FournisseurList({super.key});

  @override
  State<FournisseurList> createState() => _FournisseurListState();
}

class _FournisseurListState extends State<FournisseurList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadFournisseurs();
  }

  @override
  void dispose() {
    _isMounted = false;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFournisseurs() async {
    final provider = Provider.of<FournisseurProvider>(context, listen: false);
    await provider.loadFournisseurs();

    if (!_isMounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Fournisseurs',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: _loadFournisseurs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isSmallScreen),
          Expanded(child: _buildFournisseurList(isSmallScreen)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        onPressed: () => _navigateToAddFournisseur(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddFournisseur(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FournisseurScreen(
          fournisseurData: {
            'type': 'Personne',
            'nom': '',
            'prenom': '',
            'entreprise': '',
            'email': '',
            'telephone': '',
            'adresse': '',
            'matricule': '',
            'evaluation': '',
            'delaiLivraisonMoyen': '',
            'conditionsPaiement': '',
            'notes': '',
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un fournisseur...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildFournisseurList(bool isSmallScreen) {
    return Consumer<FournisseurProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.fournisseurs.isEmpty) {
          return _buildEmptyState(context);
        }

        final filteredFournisseurs = _filterFournisseurs(provider.fournisseurs);

        if (filteredFournisseurs.isEmpty) {
          return _buildNoResultsState();
        }

        return RefreshIndicator(
          onRefresh: _loadFournisseurs,
          child: ListView.builder(
            itemCount: filteredFournisseurs.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              return _buildFournisseurCard(
                context, 
                filteredFournisseurs[index], 
                isSmallScreen
              );
            },
          ),
        );
      },
    );
  }

  List<Fournisseur> _filterFournisseurs(List<Fournisseur> fournisseurs) {
    return fournisseurs.where((fournisseur) {
      final name = fournisseur.type == 'Entreprise' 
          ? (fournisseur.entreprise?.toString().toLowerCase() ?? '')
          : '${fournisseur.prenom?.toString().toLowerCase() ?? ''} '
            '${fournisseur.nom?.toString().toLowerCase() ?? ''}'.trim();
      
      return name.contains(_searchQuery) || 
             (fournisseur.email?.toString().toLowerCase() ?? '').contains(_searchQuery) || 
             (fournisseur.telephone?.toString().toLowerCase() ?? '').contains(_searchQuery) ||
             (fournisseur.matricule?.toString().toLowerCase() ?? '').contains(_searchQuery);
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppTheme.darkGrey),
          const SizedBox(height: 16),
          const Text('Aucun fournisseur trouvé'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToAddFournisseur(context),
            child: const Text('Ajouter un fournisseur'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppTheme.darkGrey),
          const SizedBox(height: 16),
          Text('Aucun résultat pour "$_searchQuery"'),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            child: const Text('Effacer la recherche'),
          ),
        ],
      ),
    );
  }

  Widget _buildFournisseurCard(
    BuildContext context, 
    Fournisseur fournisseur,
    bool isSmallScreen
  ) {
    final name = fournisseur.type == 'Entreprise' 
        ? fournisseur.entreprise?.toString() ?? 'Entreprise'
        : '${fournisseur.prenom?.toString() ?? ''} '
          '${fournisseur.nom?.toString() ?? ''}'.trim();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.secondaryColor,
          child: Icon(
            fournisseur.type == 'Entreprise' ? Icons.business : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildInfoRow(Icons.email, fournisseur.email?.toString() ?? 'Pas d\'email'),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.phone, fournisseur.telephone?.toString() ?? 'Pas de téléphone'),
            if (fournisseur.evaluation != null) ...[
              const SizedBox(height: 4),
              _buildInfoRow(Icons.star, 'Évaluation: ${fournisseur.evaluation}'),
            ],
          ],
        ),
        trailing: isSmallScreen 
            ? IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showFournisseurOptions(context, fournisseur),
              )
            : _buildActionButtons(context, fournisseur),
        onTap: () => _navigateToDetailScreen(context, fournisseur),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.darkGrey),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Fournisseur fournisseur) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, color: AppTheme.darkGrey),
          onPressed: () => _navigateToDetailScreen(context, fournisseur),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
          onPressed: () => _navigateToEditScreen(context, fournisseur),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
          onPressed: () => _confirmDelete(context, fournisseur),
        ),
      ],
    );
  }

  void _navigateToDetailScreen(BuildContext context, Fournisseur fournisseur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FournisseurDetailScreen(fournisseur: fournisseur),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, Fournisseur fournisseur) {
    Map<String, dynamic> fournisseurData = {
      'type': fournisseur.type ?? 'Personne',
      'nom': fournisseur.nom ?? '',
      'prenom': fournisseur.prenom ?? '',
      'entreprise': fournisseur.entreprise ?? '',
      'email': fournisseur.email ?? '',
      'telephone': fournisseur.telephone ?? '',
      'adresse': fournisseur.adresse ?? '',
      'matricule': fournisseur.matricule ?? '',
      'evaluation': fournisseur.evaluation?.toString() ?? '',
      'delaiLivraisonMoyen': fournisseur.delaiLivraisonMoyen?.toString() ?? '',
      'conditionsPaiement': fournisseur.conditionsPaiement ?? '',
      'notes': fournisseur.notes ?? '',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FournisseurScreen(
          fournisseurData: fournisseurData,
          fournisseurId: fournisseur.id,
        ),
      ),
    );
  }

  void _showFournisseurOptions(BuildContext context, Fournisseur fournisseur) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility_outlined),
            title: const Text('Voir détails'),
            onTap: () {
              Navigator.pop(ctx);
              _navigateToDetailScreen(context, fournisseur);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: Colors.blue),
            title: const Text('Modifier'),
            onTap: () {
              Navigator.pop(ctx);
              _navigateToEditScreen(context, fournisseur);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            title: const Text('Supprimer'),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDelete(context, fournisseur);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Fournisseur fournisseur) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer ${fournisseur.entreprise ?? fournisseur.nom} ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<FournisseurProvider>(context, listen: false);
        await provider.deleteFournisseur(fournisseur.id.toString());
        
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Fournisseur supprimé avec succès')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur lors de la suppression: ${e.toString()}')),
        );
      }
    }
  }
}

class FournisseurDetailScreen extends StatelessWidget {
  final Fournisseur fournisseur;

  const FournisseurDetailScreen({super.key, required this.fournisseur});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails fournisseur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Map<String, dynamic> fournisseurData = {
                'type': fournisseur.type ?? 'Personne',
                'nom': fournisseur.nom ?? '',
                'prenom': fournisseur.prenom ?? '',
                'entreprise': fournisseur.entreprise ?? '',
                'email': fournisseur.email ?? '',
                'telephone': fournisseur.telephone ?? '',
                'adresse': fournisseur.adresse ?? '',
                'matricule': fournisseur.matricule ?? '',
                'evaluation': fournisseur.evaluation?.toString() ?? '',
                'delaiLivraisonMoyen': fournisseur.delaiLivraisonMoyen?.toString() ?? '',
                'conditionsPaiement': fournisseur.conditionsPaiement ?? '',
                'notes': fournisseur.notes ?? '',
              };
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FournisseurScreen(
                    fournisseurData: fournisseurData,
                    fournisseurId: fournisseur.id,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 16),
            _buildInfoSection('Coordonnées', Icons.contact_mail, [
              _buildInfoItem(Icons.email, 'Email', fournisseur.email ?? 'Non renseigné'),
              _buildInfoItem(Icons.phone, 'Téléphone', fournisseur.telephone ?? 'Non renseigné'),
              _buildInfoItem(Icons.location_on, 'Adresse', fournisseur.adresse ?? 'Non renseigné'),
            ]),
            if (fournisseur.type == 'Entreprise') ...[
              const SizedBox(height: 16),
              _buildInfoSection('Entreprise', Icons.business, [
                _buildInfoItem(Icons.receipt, 'Matricule', fournisseur.matricule ?? 'Non renseigné'),
              ]),
            ],
            const SizedBox(height: 16),
            _buildInfoSection('Détails', Icons.info, [
              if (fournisseur.evaluation != null)
                _buildInfoItem(Icons.star, 'Évaluation', '${fournisseur.evaluation}/10'),
              if (fournisseur.delaiLivraisonMoyen != null)
                _buildInfoItem(Icons.timer, 'Délai livraison', 
                  '${fournisseur.delaiLivraisonMoyen} jours'),
              if (fournisseur.conditionsPaiement != null)
                _buildInfoItem(Icons.payment, 'Conditions paiement', 
                  fournisseur.conditionsPaiement ?? 'Non renseigné'),
            ]),
            if (fournisseur.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildInfoSection('Notes', Icons.notes, [
                _buildInfoItem(Icons.comment, 'Commentaires', fournisseur.notes ?? ''),
              ]),
            ],
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.secondaryColor,
              child: Icon(
                fournisseur.type == 'Entreprise' ? Icons.business : Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              fournisseur.type == 'Entreprise' 
                  ? fournisseur.entreprise ?? 'Entreprise'
                  : '${fournisseur.prenom ?? ''} ${fournisseur.nom ?? ''}'.trim(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(fournisseur.type ?? 'Fournisseur'),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              labelStyle: TextStyle(color: AppTheme.primaryColor),
            ),
            if (fournisseur.evaluation != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${fournisseur.evaluation}/10',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: 
       EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.darkGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.darkGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Modifier'),
          onPressed: () {
            Map<String, dynamic> fournisseurData = {
              'type': fournisseur.type ?? 'Personne',
              'nom': fournisseur.nom ?? '',
              'prenom': fournisseur.prenom ?? '',
              'entreprise': fournisseur.entreprise ?? '',
              'email': fournisseur.email ?? '',
              'telephone': fournisseur.telephone ?? '',
              'adresse': fournisseur.adresse ?? '',
              'matricule': fournisseur.matricule ?? '',
              'evaluation': fournisseur.evaluation?.toString() ?? '',
              'delaiLivraisonMoyen': fournisseur.delaiLivraisonMoyen?.toString() ?? '',
              'conditionsPaiement': fournisseur.conditionsPaiement ?? '',
              'notes': fournisseur.notes ?? '',
            };
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FournisseurScreen(
                  fournisseurData: fournisseurData,
                  fournisseurId: fournisseur.id,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: const Text('Supprimer'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.errorColor,
            side: const BorderSide(color: AppTheme.errorColor),
          ),
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer ${fournisseur.entreprise ?? fournisseur.nom} ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<FournisseurProvider>(context, listen: false);
        await provider.deleteFournisseur(fournisseur.id.toString());
        
        if (!context.mounted) return;
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Fournisseur supprimé avec succès')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur lors de la suppression: ${e.toString()}')),
        );
      }
    }
  }
}
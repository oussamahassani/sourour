import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

final uuid = Uuid();

// Theme configuration
class AppTheme {
  static const Color primaryColor = Color(0xFF009688); // Teal 500
  static const Color accentColor = Color(0xFF4DB6AC); // Teal 300
  static const Color darkTeal = Color(0xFF00796B); // Teal 700
  static const Color lightTeal = Color(0xFFE0F2F1); // Teal 50
  static const Color errorColor = Color(0xFFE57373); // Red 300
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          error: errorColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: errorColor, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: textSecondary),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
      );
}

// Data models
class FinanceRecord {
  final String id;
  final DateTime date;
  final String type;
  final double amount;
  final double tvaAchat;
  final double tvaVente;
  final double tvaDeductible;
  final double tvaCollectee;
  final double tvaNet;
  final String? description;
  final String? reference;
  final String? category;

  FinanceRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.tvaAchat,
    required this.tvaVente,
    required this.tvaDeductible,
    required this.tvaCollectee,
    required this.tvaNet,
    this.description,
    this.reference,
    this.category,
  });

  // Create a copy with modified fields
  FinanceRecord copyWith({
    String? id,
    DateTime? date,
    String? type,
    double? amount,
    double? tvaAchat,
    double? tvaVente,
    double? tvaDeductible,
    double? tvaCollectee,
    double? tvaNet,
    String? description,
    String? reference,
    String? category,
  }) {
    return FinanceRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      tvaAchat: tvaAchat ?? this.tvaAchat,
      tvaVente: tvaVente ?? this.tvaVente,
      tvaDeductible: tvaDeductible ?? this.tvaDeductible,
      tvaCollectee: tvaCollectee ?? this.tvaCollectee,
      tvaNet: tvaNet ?? this.tvaNet,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      category: category ?? this.category,
    );
  }
}

// Main app
class FinanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Financière',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: FinanceScreen(),
    );
  }
}

// Main screen
class FinanceScreen extends StatefulWidget {
  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  final List<FinanceRecord> _records = [];
  final _searchController = TextEditingController();
  String _filterType = 'Tous';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  TabController? _tabController;
  
  final List<String> _recordTypes = ['Achat', 'Vente', 'Frais', 'Autre'];
  final List<String> _categories = [
    'Matériel',
    'Services',
    'Prestations',
    'Fournitures',
    'Taxes',
    'Salaires',
    'Loyer',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    setState(() {
      _records.addAll([
        FinanceRecord(
          id: uuid.v4(),
          date: DateTime.now().subtract(Duration(days: 2)),
          type: 'Vente',
          amount: 1200.00,
          tvaAchat: 0.00,
          tvaVente: 200.00,
          tvaDeductible: 0.00,
          tvaCollectee: 200.00,
          tvaNet: 200.00,
          description: 'Vente de produits',
          reference: 'INV-001',
          category: 'Prestations',
        ),
        FinanceRecord(
          id: uuid.v4(),
          date: DateTime.now().subtract(Duration(days: 5)),
          type: 'Achat',
          amount: 450.00,
          tvaAchat: 90.00,
          tvaVente: 0.00,
          tvaDeductible: 90.00,
          tvaCollectee: 0.00,
          tvaNet: -90.00,
          description: 'Achat fournitures',
          reference: 'F2025-042',
          category: 'Fournitures',
        ),
      ]);
    });
  }

  List<FinanceRecord> get _filteredRecords {
    return _records.where((record) {
      // Apply type filter
      if (_filterType != 'Tous' && record.type != _filterType) {
        return false;
      }
      
      // Apply date range filter
      if (_filterStartDate != null && record.date.isBefore(_filterStartDate!)) {
        return false;
      }
      if (_filterEndDate != null && record.date.isAfter(_filterEndDate!.add(Duration(days: 1)))) {
        return false;
      }
      
      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        return record.description?.toLowerCase().contains(searchTerm) == true ||
            record.reference?.toLowerCase().contains(searchTerm) == true ||
            record.type.toLowerCase().contains(searchTerm) ||
            record.amount.toString().contains(searchTerm) ||
            record.category?.toLowerCase().contains(searchTerm) == true;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion Financière', style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Tableau de bord'),
            Tab(text: 'Transactions'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildTransactionsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboard() {
    final totalIncome = _records
        .where((r) => r.type.toLowerCase() == 'vente')
        .fold<double>(0.0, (sum, r) => sum + r.amount);
    
    final totalExpense = _records
        .where((r) => r.type.toLowerCase() == 'achat' || r.type.toLowerCase() == 'frais')
        .fold<double>(0.0, (sum, r) => sum + r.amount);
    
    final totalTVA = _records.fold<double>(0.0, (sum, r) => sum + r.tvaNet);
    
    final netBalance = totalIncome - totalExpense;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial summary section
          Text(
            'Résumé Financier',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Revenus',
                  totalIncome,
                  Icons.arrow_upward,
                  Colors.green[700]!,
                  Colors.green[50]!,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Dépenses',
                  totalExpense,
                  Icons.arrow_downward,
                  Colors.red[700]!,
                  Colors.red[50]!,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Bilan',
                  netBalance,
                  Icons.account_balance,
                  netBalance >= 0 ? Colors.green[700]! : Colors.red[700]!,
                  netBalance >= 0 ? Colors.green[50]! : Colors.red[50]!,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'TVA',
                  totalTVA,
                  Icons.euro,
                  AppTheme.darkTeal,
                  AppTheme.lightTeal,
                ),
              ),
            ],
          ),
          
          // Recent transactions section
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton.icon(
                icon: Icon(Icons.visibility),
                label: Text('Voir tout'),
                onPressed: () {
                  _tabController!.animateTo(1);
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          
          // Recent transactions list
          _records.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text(
                          'Aucune transaction',
                          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: _records
                      .take(5)
                      .map((record) => _buildTransactionItem(record))
                      .toList(),
                ),
          
          // Quick actions section
          SizedBox(height: 24),
          Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Nouvelle vente',
                  Icons.add_shopping_cart,
                  () => _showAddEditDialog(initialType: 'Vente'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Nouvel achat',
                  Icons.shopping_bag,
                  () => _showAddEditDialog(initialType: 'Achat'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Exporter',
                  Icons.file_download,
                  () => _showExportDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppTheme.primaryColor),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon, Color color, Color bgColor) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: bgColor,
                  radius: 16,
                  child: Icon(icon, size: 18, color: color),
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(amount)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('Tous'),
              ..._recordTypes.map((type) => _buildFilterChip(type)),
            ],
          ),
        ),
        
        // Transactions list
        Expanded(
          child: _filteredRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Aucune transaction trouvée',
                        style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 80),
                  itemCount: _filteredRecords.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionItem(_filteredRecords[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterType == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: Colors.white,
        selectedColor: AppTheme.lightTeal,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
        ),
        onSelected: (selected) {
          setState(() {
            _filterType = selected ? label : 'Tous';
          });
        },
      ),
    );
  }

  Widget _buildTransactionItem(FinanceRecord record) {
    final isIncome = record.type.toLowerCase() == 'vente';
    var color = isIncome ? Colors.green[700] : Colors.red[700];
    var bgColor = isIncome ? Colors.green[50] : Colors.red[50];
    var icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;
    
    if (record.type.toLowerCase() == 'autre') {
      color = Colors.blue[700];
      bgColor = Colors.blue[50];
      icon = Icons.swap_horiz;
    } else if (record.type.toLowerCase() == 'frais') {
      color = Colors.orange[700];
      bgColor = Colors.orange[50];
      icon = Icons.payments;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _showDetailsBottomSheet(record),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: bgColor,
                radius: 20,
                child: Icon(icon, color: color),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.description ?? record.type,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category, size: 12, color: AppTheme.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          record.category ?? 'Non catégorisé',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.calendar_today, size: 12, color: AppTheme.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(record.date),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(record.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (record.reference != null && record.reference!.isNotEmpty)
                    Text(
                      'Réf: ${record.reference}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsBottomSheet(FinanceRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Détails de la transaction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Type', record.type),
                      _buildDetailRow('Montant', '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(record.amount)}'),
                      _buildDetailRow('Date', DateFormat('dd/MM/yyyy').format(record.date)),
                      if (record.category != null)
                        _buildDetailRow('Catégorie', record.category!),
                      if (record.reference != null && record.reference!.isNotEmpty)
                        _buildDetailRow('Référence', record.reference!),
                      if (record.description != null && record.description!.isNotEmpty)
                        _buildDetailRow('Description', record.description!),
                      
                      Divider(height: 24),
                      Text(
                        'Détails TVA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildDetailRow('TVA Achat', '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(record.tvaAchat)}'),
                      _buildDetailRow('TVA Vente', '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(record.tvaVente)}'),
                      _buildDetailRow('TVA Déductible', '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(record.tvaDeductible)}'),
                      _buildDetailRow('TVA Collectée', '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(record.tvaCollectee)}'),
                      _buildDetailRow('TVA Nette', '${NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2).format(record.tvaNet)}',
                        valueColor: record.tvaNet >= 0 ? Colors.green[700] : Colors.red[700]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _editRecord(record);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text('Supprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(record);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? startDate = _filterStartDate;
        DateTime? endDate = _filterEndDate;
        String filterType = _filterType;
        
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.filter_list, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Filtres'),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type de transaction', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('Tous'),
                          selected: filterType == 'Tous',
                          onSelected: (selected) {
                            if (selected) {
                              setStateDialog(() {
                                filterType = 'Tous';
                              });
                            }
                          },
                        ),
                        ..._recordTypes.map((type) => ChoiceChip(
                          label: Text(type),
                          selected: filterType == type,                          onSelected: (selected) {
                            if (selected) {
                              setStateDialog(() {
                                filterType = type;
                              });
                            }
                          },
                        )).toList(),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('Période', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setStateDialog(() {
                                  startDate = date;
                                });
                              }
                            },
                            child: Text(
                              startDate == null 
                                ? 'Début' 
                                : DateFormat('dd/MM/yyyy').format(startDate!),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setStateDialog(() {
                                  endDate = date;
                                });
                              }
                            },
                            child: Text(
                              endDate == null 
                                ? 'Fin' 
                                : DateFormat('dd/MM/yyyy').format(endDate!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (startDate != null || endDate != null)
                      TextButton(
                        onPressed: () {
                          setStateDialog(() {
                            startDate = null;
                            endDate = null;
                          });
                        },
                        child: Text('Effacer la période'),
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterType = filterType;
                  _filterStartDate = startDate;
                  _filterEndDate = endDate;
                });
                Navigator.pop(context);
              },
              child: Text('Appliquer'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditDialog({FinanceRecord? record, String? initialType}) {
    final isEdit = record != null;
    final formKey = GlobalKey<FormState>();
    
    DateTime date = record?.date ?? DateTime.now();
    String type = record?.type ?? initialType ?? 'Achat';
    String amount = record?.amount.toString() ?? '';
    String tvaAchat = record?.tvaAchat.toString() ?? '';
    String tvaVente = record?.tvaVente.toString() ?? '';
    String description = record?.description ?? '';
    String reference = record?.reference ?? '';
    String category = record?.category ?? _categories.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(isEdit ? Icons.edit : Icons.add, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(isEdit ? 'Modifier transaction' : 'Nouvelle transaction'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: InputDecoration(labelText: 'Type'),
                        items: _recordTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            type = value!;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Choisissez un type' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: amount,
                        decoration: InputDecoration(
                          labelText: 'Montant',
                          prefixText: '€ ',
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Entrez un montant';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                        onChanged: (value) => amount = value,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: type == 'Achat' ? tvaAchat : tvaVente,
                              decoration: InputDecoration(
                                labelText: type == 'Achat' ? 'TVA Achat' : 'TVA Vente',
                                prefixText: '€ ',
                              ),
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Entrez un montant';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Montant invalide';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                if (type == 'Achat') {
                                  tvaAchat = value;
                                } else {
                                  tvaVente = value;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setStateDialog(() {
                              date = selectedDate;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('dd/MM/yyyy').format(date)),
                              Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(labelText: 'Catégorie'),
                        items: _categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            category = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: description,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 2,
                        onChanged: (value) => description = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: reference,
                        decoration: InputDecoration(labelText: 'Référence'),
                        onChanged: (value) => reference = value,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final amountValue = double.parse(amount);
                      final tvaAchatValue = double.tryParse(tvaAchat) ?? 0;
                      final tvaVenteValue = double.tryParse(tvaVente) ?? 0;
                      
                      // Calculate TVA values
                      double tvaDeductible = type == 'Achat' ? tvaAchatValue : 0;
                      double tvaCollectee = type == 'Vente' ? tvaVenteValue : 0;
                      double tvaNet = tvaCollectee - tvaDeductible;

                      final newRecord = FinanceRecord(
                        id: record?.id ?? uuid.v4(),
                        date: date,
                        type: type,
                        amount: amountValue,
                        tvaAchat: tvaAchatValue,
                        tvaVente: tvaVenteValue,
                        tvaDeductible: tvaDeductible,
                        tvaCollectee: tvaCollectee,
                        tvaNet: tvaNet,
                        description: description.isNotEmpty ? description : null,
                        reference: reference.isNotEmpty ? reference : null,
                        category: category,
                      );

                      if (isEdit) {
                        _updateRecord(record!, newRecord);
                      } else {
                        _addRecord(newRecord);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEdit ? 'Modifier' : 'Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.file_download, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Exporter les données'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choisissez le format d\'export:'),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.grid_on),
                title: Text('CSV (Excel)'),
                onTap: () {
                  Navigator.pop(context);
                  _exportToCSV();
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _exportToPDF();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _exportToCSV() {
    // In a real app, you would implement CSV export logic here
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export CSV en cours de développement'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportToPDF() {
    // In a real app, you would implement PDF export logic here
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export PDF en cours de développement'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addRecord(FinanceRecord record) {
    setState(() {
      _records.add(record);
      _records.sort((a, b) => b.date.compareTo(a.date));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction ajoutée avec succès'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editRecord(FinanceRecord record) {
    _showAddEditDialog(record: record);
  }

  void _updateRecord(FinanceRecord oldRecord, FinanceRecord newRecord) {
    setState(() {
      final index = _records.indexWhere((r) => r.id == oldRecord.id);
      if (index != -1) {
        _records[index] = newRecord;
        _records.sort((a, b) => b.date.compareTo(a.date));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction mise à jour avec succès'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete(FinanceRecord record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer cette transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
              ),
              onPressed: () {
                _deleteRecord(record);
                Navigator.pop(context);
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRecord(FinanceRecord record) {
    setState(() {
      _records.removeWhere((r) => r.id == record.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction supprimée avec succès'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
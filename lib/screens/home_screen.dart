import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wastage_item.dart';
import '../services/database_helper.dart';
import '../services/pdf_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedCategory = 'Vegetables';
  
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<WastageItem> _todayItems = [];
  bool _isLoading = true;

  final List<String> _categories = ['Vegetables', 'Fruits', 'Bakery', 'Dairy', 'Meat', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadTodayWastage();
  }

  Future<void> _loadTodayWastage() async {
    setState(() => _isLoading = true);
    _todayItems = await _dbHelper.getWastagesByDate(DateTime.now());
    setState(() => _isLoading = false);
  }

  Future<void> _saveWastage() async {
    if (_formKey.currentState!.validate()) {
      final newItem = WastageItem(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        weight: double.parse(_weightController.text.trim()),
        date: DateTime.now(),
      );

      await _dbHelper.insertWastage(newItem);
      
      _nameController.clear();
      _weightController.clear();
      
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wastage record saved successfully')),
        );
      }
      
      _loadTodayWastage();
    }
  }

  Future<void> _generateReport() async {
    if (_todayItems.isEmpty) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No records to generate report')),
        );
      }
      return;
    }
    await PdfService.generateDailyReport(_todayItems, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wastage Tracker'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Report',
            onPressed: _generateReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Input Form Card
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Record New Wastage',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          prefixIcon: Icon(Icons.shopping_basket),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter item name' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          prefixIcon: Icon(Icons.scale),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter weight';
                          if (double.tryParse(value) == null) return 'Please enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _saveWastage,
                        icon: const Icon(Icons.save),
                        label: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Save Record', style: TextStyle(fontSize: 16)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Daily List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Wastage',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
            _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _todayItems.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No wastage recorded today. Great job!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _todayItems.length,
                      itemBuilder: (context, index) {
                        final item = _todayItems[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          elevation: 1,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.errorContainer,
                              child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${item.category} • ${DateFormat('hh:mm a').format(item.date)}'),
                            trailing: Text(
                              '${item.weight.toStringAsFixed(2)} kg',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.error),
                            ),
                            onTap: () {
                               // Tap to delete confirmation maybe
                            },
                            onLongPress: () async {
                              // Direct delete
                              if (item.id != null) {
                                  await _dbHelper.deleteWastage(item.id!);
                                  _loadTodayWastage();
                                  if(mounted){
                                     ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Record deleted')),
                                     );
                                  }
                              }
                            },
                          ),
                        );
                      },
                    ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}

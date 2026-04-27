import 'package:flutter/material.dart';

class ContractsDashboard extends StatefulWidget {
  const ContractsDashboard({super.key});

  @override
  State<ContractsDashboard> createState() => _ContractsDashboardState();
}

class _ContractsDashboardState extends State<ContractsDashboard> {
  final Color posteBlue = const Color(0xFF001A70);
  final Color posteYellow = const Color(0xFFFFC20E);

  String selectedDirection = 'Toutes les Directions';

  // --- LOGIQUE DE RETOUR GÉNÉRALE ---
  void _goToDashboard() {
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: posteBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        // Flèche de retour standard dans l'AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: _goToDashboard,
        ),
        title: const Text("Gestion par Direction", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      
      body: SingleChildScrollView( // Pour éviter les erreurs de pixels sur petits écrans
        child: Column(
          children: [
            _buildFilterBar(),
            
            // --- SECTION SCANNER AVEC BOUTON RETOUR INTÉGRÉ ---
            _buildUploadCard(),
            
            // Simulation de liste
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("CONTRATS RÉCENTS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            _buildDummyList(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET : LA CARTE D'UPLOAD AVEC OPTION RETOUR ---
  Widget _buildUploadCard() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: posteBlue.withOpacity(0.1)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: posteBlue, size: 30),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text("Scanner un nouveau contrat", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // BOUTON RETOUR (Annuler)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goToDashboard,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: posteBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("RETOUR", style: TextStyle(color: posteBlue, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                // BOUTON SCANNER (Action principale)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Ton code FilePicker ici
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: posteYellow,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("SCANNER", 
                      style: TextStyle(color: Color(0xFF001A70), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedDirection,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.filter_list, color: posteBlue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: ['Toutes les Directions', 'Informatique', 'Finance', 'RH']
            .map((dir) => DropdownMenuItem(value: dir, child: Text(dir))).toList(),
        onChanged: (val) => setState(() => selectedDirection = val!),
      ),
    );
  }

  Widget _buildDummyList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(Icons.description, color: posteBlue),
          title: Text("Contrat #2024-00${index + 1}"),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
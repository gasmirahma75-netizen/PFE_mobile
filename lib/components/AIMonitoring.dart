import 'package:flutter/material.dart';

// ✅ CORRECTION : Changement de AlMonitoring vers AIMonitoring
class AIMonitoring extends StatelessWidget {
  const AIMonitoring({super.key});

  void _showMonitoringDetails(BuildContext context) {
    const Color posteBlue = Color(0xFF001A70);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.memory, color: posteBlue, size: 30),
                const SizedBox(width: 12),
                const Text(
                  "Détails du Système IA",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: posteBlue),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.speed, "Temps de réponse", "1.2s (Moyen)"),
            _buildDetailRow(Icons.layers, "Architecture", "Transformer (LayoutLM v3)"),
            _buildDetailRow(Icons.storage, "Backend", "FastAPI / Python 3.10"),
            _buildDetailRow(Icons.check_circle, "Statut Serveur", "Opérationnel", color: Colors.green),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: posteBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Fermer", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color posteBlue = Color(0xFF001A70);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showMonitoringDetails(context),
        splashColor: posteBlue.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: posteBlue),
                  const SizedBox(width: 10),
                  const Text(
                    "AI Monitoring System",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: posteBlue),
                  ),
                  const Spacer(),
                  _buildLiveIndicator(),
                ],
              ),
              const Divider(height: 25),

              _buildMetricTile("Moteur OCR", "PaddleOCR v2.8", Icons.document_scanner_outlined),
              _buildMetricTile("Modèle NLP", "LayoutLM v3", Icons.psychology_outlined),
              _buildMetricTile("Serveur", "FastAPI (Python)", Icons.terminal_outlined),

              const SizedBox(height: 15),
              
              const Text("Précision d'extraction", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.984,
                backgroundColor: Colors.grey.shade200,
                color: Colors.green.shade600,
                minHeight: 6,
              ),
              const SizedBox(height: 5),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("98.4%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: Colors.green),
          SizedBox(width: 5),
          Text("LIVE", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
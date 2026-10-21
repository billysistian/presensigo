import 'package:flutter/material.dart';
import 'package:presensi_gac/utils/tanggal_indo.dart';

class ProgramDetailScreen extends StatefulWidget {
  final String title;
  final String image;
  final String description;
  final String startDate;
  final String endDate;

  const ProgramDetailScreen({
    super.key,
    required this.title,
    required this.image,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Title muncul ketika scroll lebih dari 100
      if (_scrollController.offset > 100 && !_showTitle) {
        setState(() => _showTitle = true);
      } else if (_scrollController.offset <= 100 && _showTitle) {
        setState(() => _showTitle = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ===== App Bar =====
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: _showTitle ? 2 : 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back,
                  color: _showTitle ? Colors.black87 : const Color(0xFF163A56),
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: AnimatedOpacity(
              opacity: _showTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // ===== Banner Gambar =====
          SliverToBoxAdapter(
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: Image.network(
                widget.image.startsWith("http")
                    ? widget.image
                    : "https://payroll.gomega.co.id/storage/${widget.image}",
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
          ),

          // ===== Content Section =====
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Periode Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Periode Program",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${formatBulanPendek(widget.startDate)} - ${formatBulanPendek(widget.endDate)}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: Colors.grey.shade200, height: 1),

                  const SizedBox(height: 24),

                  // Description Label
                  Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description Text
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

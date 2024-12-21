import 'package:flutter/material.dart';
import 'stall_qr_setup_screen.dart'; // Import StallQRSetupScreen
import '../services/ghc_services.dart';

class GHCListScreen extends StatefulWidget {
  final String ownerId;

  const GHCListScreen({Key? key, required this.ownerId}) : super(key: key);

  @override
  _GHCListScreenState createState() => _GHCListScreenState();
}

class _GHCListScreenState extends State<GHCListScreen> {
  final GHCServices _ghcServices = GHCServices();
  List<dynamic> _ghcList = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGHCList();
  }

  Future<void> _fetchGHCList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _ghcServices.fetchGHCsByOwner(widget.ownerId);
      if (response['success'] == true) {
        setState(() {
          _ghcList = response['data'];
        });
      } else {
        setState(() {
          _errorMessage = response['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToStallQRSetupScreen(String ghcId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StallQRSetupScreen(ghcId: ghcId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Danh sách gian hàng",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      )
          : _errorMessage != null
          ? Center(
        child: Text(
          _errorMessage!,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.red,
          ),
        ),
      )
          : _ghcList.isEmpty
          ? Center(
        child: Text(
          "Không có gian hàng nào",
          style: theme.textTheme.bodyLarge,
        ),
      )
          : ListView.builder(
        itemCount: _ghcList.length,
        itemBuilder: (context, index) {
          final ghc = _ghcList[index];
          return GestureDetector(
            onTap: () =>
                _navigateToStallQRSetupScreen(ghc['_id']),
            child: Card(
              margin: const EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Stack(
                children: [
                  // Image filling the card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: ghc['photos'].isNotEmpty
                        ? Image.network(
                      ghc['photos'][0],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      'https://via.placeholder.com/150',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Label overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius:
                        const BorderRadius.vertical(
                          bottom: Radius.circular(15.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            ghc['name'],
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 1.0),
                          Text(
                            ghc['description'],
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
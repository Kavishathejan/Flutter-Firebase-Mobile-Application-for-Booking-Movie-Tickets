import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  static const routeName = '/seatSelection';
  final String movieId, showtimeId, movieTitle;
  SeatSelectionScreen({
    required this.movieId,
    required this.showtimeId,
    required this.movieTitle,
  });

  @override
  _SeatSelectionScreenState createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  List<String> selected = [];
  Map<String, dynamic>? showtimeData;
  bool loading = false;
  double price = 0.0;

  @override
  void initState() {
    super.initState();
    _loadShowtime();
  }

  Future<void> _loadShowtime() async {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final snap = await fs.getShowtime(widget.movieId, widget.showtimeId);
    final data = snap.data() as Map<String, dynamic>;
    setState(() {
      showtimeData = data;
      price = (data['price'] ?? 0).toDouble();
    });
  }

  Widget seatButton(String id, List booked) {
    final isBooked = booked.contains(id);
    final isSelected = selected.contains(id);
    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  selected.remove(id);
                } else {
                  selected.add(id);
                }
              });
            },
      child: Container(
        margin: EdgeInsets.all(4),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey.shade600
              : isSelected
                  ? const Color.fromARGB(255, 48, 10, 219)
                  : Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          id,
          style: TextStyle(
            fontSize: 10,
            color: isBooked ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);

    if (showtimeData == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final rows = showtimeData!['rows'] ?? 5;
    final cols = showtimeData!['cols'] ?? 8;
    final booked = List<String>.from(showtimeData!['bookedSeats'] ?? []);

    
    List<Widget> seatWidgets = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final seatId = '${String.fromCharCode(65 + r)}${c + 1}';
        seatWidgets.add(seatButton(seatId, booked));
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF0a0a0a),
      appBar: AppBar(
        title: Text(
          'Select Seats - ${widget.movieTitle}',
          style: TextStyle(fontSize: 18,color: Colors.white),
        ),
        backgroundColor: Colors.black
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Tap to select seats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 55, 115, 255),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Price per seat: \$${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              children: seatWidgets,
            ),
            SizedBox(height: 16),
            Text(
              selected.isEmpty
                  ? 'No seats selected'
                  : 'Selected: ${selected.join(', ')}',
              style: TextStyle(fontSize: 14,color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 55, 115, 255),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Confirm (${selected.length} seats)',
                      style: TextStyle(fontSize: 16,color:Colors.white),
                    ),
              onPressed: selected.isEmpty
                  ? null
                  : () async {
                      setState(() => loading = true);
                      try {
                        final user = auth.currentUser;
                        if (user == null) throw Exception('Not logged in');
                        final total = selected.length * price;
                        await fs.bookSeats(
                          movieId: widget.movieId,
                          showtimeId: widget.showtimeId,
                          userId: user.uid,
                          movieTitle: widget.movieTitle,
                          seats: selected,
                          totalPrice: total,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking confirmed!'),
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking failed: ${e.toString()}'),
                          ),
                        );
                      } finally {
                        setState(() => loading = false);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}

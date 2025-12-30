import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/request_model.dart'; // Ensure this points to your Request model
import '../../services/firestore_service.dart';

class UserRequestEditPage extends StatefulWidget {
  final AssetRequest request; // The existing request object

  const UserRequestEditPage({super.key, required this.request});

  @override
  State<UserRequestEditPage> createState() => _UserRequestEditPageState();
}

class _UserRequestEditPageState extends State<UserRequestEditPage> {
  final FirestoreService _firestoreService = FirestoreService();

  late DateTime _selectedDate;
  String? _selectedTime;
  late TextEditingController _reasonController;
  bool _isLoading = false;

  // Matching your exact time list for consistency
  final List<String> _times = [
    "8:00 AM",
    "9:00 AM",
    "10:00 AM",
    "01:00 PM",
    "2:00 PM",
    "03:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // 1. Set Date
    _selectedDate = widget.request.requiredDate;

    // 2. Set Reason
    _reasonController = TextEditingController();

    // 3. Attempt to match the existing time to your Chips
    // We format the existing date to see if it matches any string in _times
    String formattedTime =
        DateFormat('h:mm a').format(widget.request.requiredDate);
    String formattedTimeWithPad =
        DateFormat('hh:mm a').format(widget.request.requiredDate);

    if (_times.contains(formattedTime)) {
      _selectedTime = formattedTime;
    } else if (_times.contains(formattedTimeWithPad)) {
      _selectedTime = formattedTimeWithPad;
    } else {
      // If the saved time doesn't match the chips exactly, user must re-select
      _selectedTime = null;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // Combine Date + Time Chip into one DateTime
  DateTime _combineDateTime() {
    if (_selectedTime == null) return _selectedDate;

    final timeFormat = DateFormat('hh:mm a');
    // Handle the generic '2:00 PM' vs '02:00 PM' parsing looseness
    final timeStr =
        _selectedTime!.length == 7 ? "0$_selectedTime" : _selectedTime!;

    final timeParsed = timeFormat.parse(timeStr);

    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      timeParsed.hour,
      timeParsed.minute,
    );
  }

  Future<void> _handleUpdate() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestoreService.editRequest(
        requestId: widget.request.id,
        assetName: widget.request.assetName,
        userName: widget.request.userName,
        newRequiredDate: _combineDateTime(),
        newReason: _reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request updated & Admins notified!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Return to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF00A7A7),
            colorScheme: const ColorScheme.light(primary: Color(0xFF00A7A7)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent editing if not PENDING
    final isEditable = widget.request.status == 'PENDING';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Request"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Info ---
            Center(
              child: Text(
                "Editing: ${widget.request.assetName}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004C5C)),
              ),
            ),
            const SizedBox(height: 8),
            if (!isEditable)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade50,
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            "This request cannot be edited because it has already been processed.")),
                  ],
                ),
              ),
            const SizedBox(height: 30),

            // --- Date Picker ---
            Text(
              "Required Date",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: const Color(0xFF004C5C),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: isEditable ? _pickDate : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isEditable ? Colors.white : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00A7A7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFF00A7A7)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // --- Time Chips ---
            Text(
              "Select Time Slot",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: const Color(0xFF004C5C),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _times.map((time) {
                final isSelected = _selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: isEditable
                      ? (_) => setState(() => _selectedTime = time)
                      : null,
                  selectedColor: const Color(0xFF00A7A7),
                  backgroundColor: const Color(0xFFEFF9F9),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF004C5C),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),

            // --- Reason Field ---
            Text(
              "Reason",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: const Color(0xFF004C5C),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              enabled: isEditable,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFEFF9F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF00A7A7), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- Action Button ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (isEditable && !_isLoading) ? _handleUpdate : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A7A7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SAVE CHANGES",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

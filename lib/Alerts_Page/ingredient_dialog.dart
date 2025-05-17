import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/Alerts_Page/ingredient.dart';

class AddIngredientDialog extends StatefulWidget {
  final void Function(Ingredient) onAdd;

  const AddIngredientDialog({super.key, required this.onAdd});

  @override
  State<AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Ingredient"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              maxLines: null,
              minLines: 1,
              decoration: const InputDecoration(
                //contentPadding: EdgeInsets.only(left: 10, right: 50, top: 35, bottom: 35),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                  color: Color.fromARGB(255, 226, 225, 225)
                  )
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                  color: Colors.black
                  )
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                labelText: "Ingredient Name",
                hintText: "e.g., Tomato",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _quantityController,
              maxLines: null,
              minLines: 1,
              decoration: const InputDecoration(
                //contentPadding: EdgeInsets.only(left: 10, right: 50, top: 35, bottom: 35),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                  color: Color.fromARGB(255, 226, 225, 225)
                  )
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                  color: Colors.black
                  )
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                labelText: "Quantity",
                hintText: "e.g., 500g, 1L",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                  color: Color.fromARGB(255, 226, 225, 225)
                  )
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                  color: Colors.black
                  )
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                labelText: "Expiry Date",
                hintText: _selectedDate == null
                    ? "年 / 月 / 日"
                    : "${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
            Text(
              "Cancel",
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black
              ),
            ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _quantityController.text.isEmpty ||
                _selectedDate == null) return;

            widget.onAdd(Ingredient(
              name: _nameController.text,
              quantity: _quantityController.text,
              expiryDate: _selectedDate!,
            ));

            Navigator.pop(context);
          },
          child: Text(
            "Add Ingredient",
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black
            ),
          ),
        ),
      ],
    );
  }
}
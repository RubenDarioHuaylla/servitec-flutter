import 'package:flutter/material.dart';

import '../../models/service_request.dart';
import '../../services/quote_service.dart';
import '../../utils/validators.dart';

import '../../utils/category_utils.dart';

import '../../widgets/custom_text_field.dart';

class CreateQuoteScreen extends StatefulWidget {
  final ServiceRequest request;

  const CreateQuoteScreen({super.key, required this.request});

  @override
  State<CreateQuoteScreen> createState() => _CreateQuoteScreenState();
}

class _CreateQuoteScreenState extends State<CreateQuoteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController durationController = TextEditingController();

  final TextEditingController messageController = TextEditingController();

  final QuoteService _quoteService = QuoteService();

  String _selectedDurationUnit = 'hours';
  bool _isSaving = false;

  @override
  void dispose() {
    priceController.dispose();
    durationController.dispose();
    messageController.dispose();

    super.dispose();
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.parse(
      priceController.text.trim().replaceAll(',', '.'),
    );

    final duration = double.parse(
      durationController.text.trim().replaceAll(',', '.'),
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await _quoteService.createQuote(
        requestId: widget.request.id,
        price: price,
        estimatedDuration: duration,
        durationUnit: _selectedDurationUnit,
        message: messageController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cotización enviada correctamente')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar la cotización: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar cotización')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.category_outlined, size: 19),
                            const SizedBox(width: 8),
                            Text(
                              CategoryUtils.getCategoryName(request.categoryId),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 19),
                            const SizedBox(width: 8),
                            Expanded(child: Text(request.address)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          request.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Datos de la cotización',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Precio',
                  hintText: 'Ejemplo: 80.00',
                  icon: Icons.payments_outlined,
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: Validators.validatePrice,
                  prefixText: 'S/ ',
                ),

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: durationController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

                        label: 'Duración estimada',
                        hintText: 'Ejemplo: 3',
                        icon: Icons.schedule_outlined,

                        validator: Validators.validateDuration,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDurationUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unidad',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'hours',
                            child: Text('Horas'),
                          ),
                          DropdownMenuItem(value: 'days', child: Text('Días')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedDurationUnit = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: messageController,
                  maxLines: 5,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje para el cliente',
                    hintText:
                        'Explica cómo realizarás el trabajo, '
                        'qué incluye el precio o cuándo puedes acudir',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.message_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.validateMessage,
                ),

                const SizedBox(height: 8),

                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'El cliente podrá revisar el precio, '
                            'el tiempo estimado y tu mensaje antes '
                            'de aceptar la cotización.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _submitQuote,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      _isSaving ? 'Enviando...' : 'Enviar cotización',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

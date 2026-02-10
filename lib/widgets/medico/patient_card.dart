import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/medico_constants.dart';
import '../../models/agenda_item_model.dart';
import '../../screens/medico/historia_clinica_medico_screen.dart';
import '../patient/common_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PatientCard extends StatelessWidget {
  final AgendaItem item;
  final bool isCurrent;
  final Color statusColor;
  final Function(String) onRemove;

  const PatientCard({
    Key? key,
    required this.item,
    required this.isCurrent,
    required this.statusColor,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrent
            ? Border.all(color: MedicoConstants.primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? MedicoConstants.primaryColor.withOpacity(0.15)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item.paciente.substring(0, 1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: MedicoConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.paciente,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: MedicoConstants.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.prioridad) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.priority_high_rounded,
                                size: 14, color: MedicoConstants.error),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.motivo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: MedicoConstants.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.estado == 'en_consultorio' || item.estado == 'en_sala') ...[
                        PulsingStatusDot(color: statusColor, size: 8),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        _formatStatus(item.estado),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (item.estado != 'atendido') ...[
            Container(
              height: 1,
              color: Colors.grey.shade100,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                children: [
                   // Minimalist Icons for ALL patients as requested
                   Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HistoriaClinicaMedicoScreen(
                            patient: {
                              'name': item.paciente,
                              'id': 'mock_id',
                              'dni': item.dni,
                            }
                          )),
                        );
                      },
                      icon: const Icon(Icons.description_outlined, size: 16),
                      label: const Text("Historia", style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: MedicoConstants.primaryColor),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showCallConfirmation(context, item.paciente),
                      icon: const Icon(Icons.notifications_none_rounded, size: 16),
                      label: const Text("Llamar", style: TextStyle(fontSize: 12)),
                       style: TextButton.styleFrom(foregroundColor: MedicoConstants.textDark),
                    ),
                  ),
                  Container(width: 1, height: 20, color: Colors.grey.shade300),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showOptions(context, item.paciente),
                      icon: const Icon(Icons.more_horiz_rounded,
                          color: Colors.grey, size: 18),
                      label: const Text("Opciones",
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'atendido':
        return 'Atendido';
      case 'en_consultorio':
        return 'En Consultorio';
      case 'en_sala':
        return 'En Sala de Espera';
      case 'confirmado':
        return 'Confirmado';
      case 'pendiente':
        return 'Pendiente';
      default:
        return status;
    }
  }

  void _showCallConfirmation(BuildContext context, String patientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Llamar a $patientName"),
        content: const Text("¿Cómo deseas realizar el llamado?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("📢 Llamando a $patientName a Sala de Espera..."),
                backgroundColor: MedicoConstants.primaryColor,
              ));
            },
            child: const Text("A Sala de Espera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("📞 Intercomunicador: Llamando a $patientName..."),
                backgroundColor: MedicoConstants.success,
              ));
            },
            child: const Text("A Consultorio (Intercom)"),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, String patientName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Opciones para $patientName",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded, color: MedicoConstants.primaryColor),
              title: const Text("Ver Historia Clínica"),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HistoriaClinicaMedicoScreen(
                    patient: {
                       'name': patientName,
                       'id': 'mock_id',
                       'dni': '12.345.678', // Mock fallback
                    }
                  )),
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.notifications_active_rounded, color: MedicoConstants.textDark),
              title: const Text("Llamar Paciente"),
              onTap: () {
                Navigator.pop(sheetContext);
                _showCallConfirmation(context, patientName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_calendar_rounded),
              title: const Text("Reprogramar Turno"),
              onTap: () {
                Navigator.pop(sheetContext); // Close bottom sheet
                _showRescheduleDialog(context, patientName); // Use original context
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.red),
              title: const Text("Cancelar Turno", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(sheetContext); // Close bottom sheet
                _showCancelDialog(context, patientName); // Use original context
              },
            ),
            ListTile(
              leading: const Icon(Icons.print_rounded),
              title: const Text("Imprimir Etiqueta"),
              onTap: () {
                Navigator.pop(sheetContext); // Close bottom sheet
                _printLabel(context, patientName); // Use original context
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, String patientName) async {
    // 1. Pick Date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: "Seleccionar Nueva Fecha",
    );

    if (pickedDate != null) {
      if (!context.mounted) return;

      // 2. Pick Time
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
        helpText: "Seleccionar Nueva Hora",
      );

      if (pickedTime != null) {
        if (!context.mounted) return;

        // 3. Confirm
        // CALL THE CALLBACK TO REMOVE ITEM
        onRemove(patientName);

        final String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
        final String formattedTime = pickedTime.format(context);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Turno de $patientName reprogramado para $formattedDate a las $formattedTime. (Eliminado de agenda de hoy)"),
          backgroundColor: MedicoConstants.warning,
          duration: const Duration(seconds: 4),
        ));
      }
    }
  }

  void _showCancelDialog(BuildContext context, String patientName) {
    final TextEditingController reasonController = TextEditingController();
    bool isButtonEnabled = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Cancelar turno de $patientName"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Text("Por favor, ingrese el motivo de la cancelación:"),
                   const SizedBox(height: 10),
                   TextField(
                     controller: reasonController,
                     decoration: const InputDecoration(
                       hintText: "Ej: Paciente no asistió, error administrativo...",
                       border: OutlineInputBorder(),
                     ),
                     maxLines: 2,
                     onChanged: (value) {
                       setState(() {
                         isButtonEnabled = value.trim().isNotEmpty;
                       });
                     },
                   ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Volver"),
                ),
                ElevatedButton(
                  onPressed: isButtonEnabled
                      ? () {
                          // CALL THE CALLBACK TO REMOVE ITEM
                          onRemove(patientName);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Turno de $patientName cancelado. Motivo: ${reasonController.text}"),
                            backgroundColor: MedicoConstants.error,
                          ));
                        }
                      : null, // Disabled if empty
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Confirmar Cancelación"),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _printLabel(BuildContext context, String patientName) async {
    try {
      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                   pw.Text("ZANOO", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                   pw.Divider(),
                   pw.SizedBox(height: 10),
                   pw.Text("PACIENTE", style: pw.TextStyle(fontSize: 12)),
                   pw.Text(patientName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                   pw.SizedBox(height: 5),
                   pw.Text("DNI: 12.345.678", style: pw.TextStyle(fontSize: 14)), // Fallback data
                   pw.SizedBox(height: 10),
                   pw.Text("FECHA: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}", style: pw.TextStyle(fontSize: 10)),
                   pw.SizedBox(height: 10),
                   pw.BarcodeWidget(
                     barcode: pw.Barcode.qrCode(),
                     data: "P-$patientName-123",
                     width: 60,
                     height: 60,
                   ),
                   pw.SizedBox(height: 10),
                   pw.Text("Etiqueta Interna", style: pw.TextStyle(fontSize: 8)),
                ],
              )
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'etiqueta_$patientName.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al generar PDF: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }
}

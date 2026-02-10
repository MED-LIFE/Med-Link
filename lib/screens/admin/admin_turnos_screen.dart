import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants/medico_constants.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/patient/standard_header.dart';
import '../../repositories/medico_repository.dart';
import '../../models/agenda_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTurnosScreen extends StatefulWidget {
  const AdminTurnosScreen({Key? key}) : super(key: key);

  @override
  State<AdminTurnosScreen> createState() => _AdminTurnosScreenState();
}

class _AdminTurnosScreenState extends State<AdminTurnosScreen> {
  final MedicoRepository _repository = MedicoRepository();
  
  String _selectedDoctor = 'Todos';
  String _selectedType = 'Consultas';
  String _selectedStudy = 'Todos';
  DateTime? _selectedDate = DateTime.now();

  final List<String> _doctors = [
    'Todos', 
    'Dr. René Favaloro', 'Dra. Cecilia Grierson', 'Dr. Salvador Mazza',
    'Dr. Luis Agote', 'Dra. Julieta Lanteri', 'Dr. Esteban L. Maradona',
    'Dra. Alicia Moreau', 'Dr. Ramón Carrillo', 'Dr. Bernardo Houssay',
    'Dra. Petrona Eyle', 'Dr. Pedro Abel Chaves'
  ];
  final List<String> _studies = ['Todos', 'Resonancia Magnética', 'Tomografía', 'Laboratorio', 'Ecografía', 'Rayos X', 'Mamografía'];
  final List<String> _types = ['Consultas', 'Estudios'];

  @override
  void initState() {
    super.initState();
    // Ensure initial data exists if needed (optional)
    _repository.seedData();
  }

  // Filter Logic
  List<AgendaItem> _filterTurns(List<AgendaItem> allTurns) {
    return allTurns.where((turn) {
      if (turn.estado == 'cancelado') return false; 
      
      // Filter by Type (Simplified logic depending on your data model)
      // Assuming 'estudio' turns have a specialty that matches a study type or explicit type field
      // For now, let's assume all seeded data are consultations unless specialty is in _studies list
      bool isEstudio = _studies.contains(turn.specialty) && turn.specialty != 'Todos';
      
      if (_selectedType == 'Consultas' && isEstudio) return false;
      if (_selectedType == 'Estudios' && !isEstudio) return false;
      
      // Filter by Resource (Doctor or Study)
      if (_selectedType == 'Consultas') {
        if (_selectedDoctor != 'Todos' && turn.doctor != _selectedDoctor) return false;
      } else {
        if (_selectedStudy != 'Todos' && turn.specialty != _selectedStudy) return false; 
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFEF9F1), // Cream Background
        drawer: const MainDrawer(role: UserRole.admin),

        body: StreamBuilder<List<AgendaItem>>(
          stream: _repository.getAgendaStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return const Center(child: Text("No hay turnos registrados en el sistema."));
            }

            final allTurns = snapshot.data!;
            final filteredTurns = _filterTurns(allTurns);

            return NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: const StandardPageHeader(
                      title: "Gestión de Turnos",
                      subtitle: "Administración de Agenda",
                      imagePath: 'assets/images/turn_management_header.png',
                      isLarge: false,
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        labelColor: Color(0xFF2376F6),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Color(0xFF2376F6),
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Tab(text: "Listado", icon: Icon(Icons.list_alt_rounded)),
                          Tab(text: "Agenda", icon: Icon(Icons.calendar_month_rounded)),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  // Tab 1: Listado
                  _buildListadoView(filteredTurns),
                  
                  // Tab 2: Agenda View
                  _buildAgendaView(allTurns), // Pass all turns to calendar, filter inside
                ],
              ),
            );
          }
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAssignTurnBottomSheet(context),
          backgroundColor: const Color(0xFF2376F6),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Asignar Turno", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildListadoView(List<AgendaItem> turns) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                   // Header
                   Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.shield_rounded, size: 20, color: Color(0xFF083866)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Admin. Laura Gómez", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF083866))),
                            Text("Supervisora de Agenda", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Filters
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.category_rounded, color: Color(0xFF2376F6), size: 20),
                            const SizedBox(width: 12),
                            const Text("Tipo:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedType,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2376F6)),
                                    style: const TextStyle(color: Color(0xFF0D1C2E), fontWeight: FontWeight.w500),
                                    items: _types.map((String value) {
                                      return DropdownMenuItem<String>(value: value, child: Text(value));
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() { 
                                        _selectedType = newValue!; 
                                        if (_selectedType == 'Consultas') _selectedDoctor = 'Todos';
                                        else _selectedStudy = 'Todos';
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(_selectedType == 'Consultas' ? Icons.person_search_rounded : Icons.science_rounded, color: const Color(0xFF2376F6), size: 20),
                            const SizedBox(width: 12),
                            Text(_selectedType == 'Consultas' ? "Profesional:" : "Estudio:", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedType == 'Consultas' ? _selectedDoctor : _selectedStudy,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2376F6)),
                                    style: const TextStyle(color: Color(0xFF0D1C2E), fontWeight: FontWeight.w500),
                                    items: (_selectedType == 'Consultas' ? _doctors : _studies).map((String value) {
                                      return DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis));
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        if (_selectedType == 'Consultas') _selectedDoctor = newValue!;
                                        else _selectedStudy = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final turn = turns[index];
                Color statusColor = _getStatusColor(turn.estado);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                               decoration: BoxDecoration(
                                 color: const Color(0xFFE3F2FD),
                                 borderRadius: BorderRadius.circular(8)
                               ),
                               child: Text(turn.hora, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2376F6)))
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(turn.estado.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF0D1C2E)),
                            const SizedBox(width: 8),
                            Text(turn.paciente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D1C2E))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(_selectedType == 'Consultas' ? Icons.medical_services_outlined : Icons.science_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text("${turn.doctor} - ${turn.specialty}", style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _showCancelConfirmation(context, turn);
                              }, 
                              icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                              label: const Text("Cancelar", style: TextStyle(color: Colors.red, fontSize: 13)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              childCount: turns.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildAgendaView(List<AgendaItem> allTurns) {
    bool hasSelection = (_selectedType == 'Consultas' && _selectedDoctor != 'Todos') || 
                        (_selectedType == 'Estudios' && _selectedStudy != 'Todos');

    if (!hasSelection) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_alt_off_rounded, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              "Seleccione un Profesional o Estudio\npara ver la agenda detallada",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    
    // In a real app we would have a Date field on AgendaItem.
    // For now we assume all turns are TODAY for this demo, or we parse from ID/Date field if added.
    // We will assume 'AgendaItem' will eventually have a DateTime date.
    // For this refactor, let's treat all items as "Today" for simplicity unless we added a date field.
    // Wait, the Mock had a date field. Our model (AgendaItem) does NOT have a Date field yet!
    // This is an issue. The real backend `AgendaItem` only has 'hora'.
    // We should probably assume they are for "Today" or add a Date field to AgendaItem.
    // Given the previous task instructions didn't specify adding Date, I'll stick to 'Today' 
    // OR create a valid date object here for display.
    
    final filteredForAgenda = _filterTurns(allTurns);
    final today = DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.only(bottom: 20),
            child: TableCalendar(
              firstDay: DateTime(2024),
              lastDay: DateTime(2026),
              focusedDay: _selectedDate ?? DateTime.now(),
              currentDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
               // Simplified event loader as we don't have multiple dates in our model yet
              eventLoader: (day) {
                 if (isSameDay(day, today)) return filteredForAgenda;
                 return [];
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(color: Color(0xFF2376F6), shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: const Color(0xFF2376F6).withOpacity(0.3), shape: BoxShape.circle),
                markerDecoration: const BoxDecoration(color: Color(0xFFF04E3E), shape: BoxShape.circle),
                markersMaxCount: 4,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, 
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFFEF9F1), // Cream BG for list
            child: Builder(
              builder: (context) {
                 final date = _selectedDate ?? DateTime.now();
                 // Show turns only if selected date is Today
                 if (!isSameDay(date, today)) {
                    return const Center(child: Text("No hay turnos para esta fecha (Demo: Solo Hoy)", style: TextStyle(color: Colors.grey)));
                 }
                 
                 final dailyTurns = filteredForAgenda; // Already filtered by dropdowns
                 
                 if (dailyTurns.isEmpty) {
                   return const Center(child: Text("No hay turnos programados", style: TextStyle(color: Colors.grey)));
                 }
                   return ListView.builder(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                     itemCount: dailyTurns.length,
                     itemBuilder: (context, index) {
                       final turn = dailyTurns[index];
                       Color statusColor = _getStatusColor(turn.estado);
                       bool isLast = index == dailyTurns.length - 1;

                       return IntrinsicHeight(
                         child: Row(
                           crossAxisAlignment: CrossAxisAlignment.stretch,
                           children: [
                             // 1. Time Column
                             SizedBox(
                               width: 60,
                               child: Padding(
                                 padding: const EdgeInsets.only(top: 0),
                                 child: Column(
                                   children: [
                                     Text(turn.hora, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2376F6))),
                                     const SizedBox(height: 2),
                                     Text( amPm(turn.hora), style: TextStyle(fontSize: 10, color: Colors.grey.withOpacity(0.9), fontWeight: FontWeight.bold)),
                                   ],
                                 ),
                               ),
                             ),
                             
                             // 2. Timeline Line & Dot
                             SizedBox(
                               width: 28,
                               child: Stack(
                                 alignment: Alignment.topCenter,
                                 children: [
                                   // Continuous Line
                                   if (!isLast)
                                     Positioned(
                                       top: 8, bottom: 0,
                                       child: Container(
                                         width: 4, 
                                         color: const Color(0xFFBDBDBD), // Darker grey for contrast
                                       )
                                     ),
                                   
                                   // Connector Dot (Inner)
                                   Container(
                                     margin: const EdgeInsets.only(top: 2),
                                     width: 20, height: 20,
                                     decoration: BoxDecoration(
                                       color: Colors.white,
                                       shape: BoxShape.circle,
                                       border: Border.all(color: _getTimelineColor(turn.estado), width: 4),
                                       boxShadow: [
                                          BoxShadow(color: _getTimelineColor(turn.estado).withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))
                                       ]
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             const SizedBox(width: 12),
                             
                             // 3. Card Content
                             Expanded(
                               child: Padding(
                                 padding: const EdgeInsets.only(bottom: 24),
                                 child: Container(
                                   padding: const EdgeInsets.all(16),
                                   decoration: BoxDecoration(
                                     color: _getCardColor(turn.estado),
                                     borderRadius: BorderRadius.circular(20),
                                     boxShadow: [
                                       BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8)),
                                       BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1))
                                     ],
                                     border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                                   ),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           Text(turn.paciente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D1C2E))),
                                            
                                            // Status Badge
                                            Container(
                                              width: 24, height: 24,
                                              decoration: BoxDecoration(
                                                color: _getTimelineColor(turn.estado),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                            ),
                                         ],
                                       ),
                                       const SizedBox(height: 6),
                                       Text(
                                          "${turn.hora} - ${turn.doctor}", 
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13)
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                           ],
                         ),
                       );
                     },
                   );
              }
            ),
          ),
        )
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmado': return Colors.green;
      case 'pendiente': return Colors.orange;
      case 'cancelado': return Colors.red;
      case 'en_consultorio': return const Color(0xFF2376F6);
      case 'atendido': return const Color(0xFF34C759);
      case 'disponible': return Colors.lightBlueAccent;
      default: return Colors.grey;
    }
  }

  void _showCancelConfirmation(BuildContext context, AgendaItem turn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancelar Turno"),
        content: Text("¿Está seguro que desea cancelar el turno de ${turn.paciente}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No, volver", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
               // In a real app we would call _repository.cancelTurn(turn.id)
               Navigator.pop(context);
               FirebaseFirestore.instance.collection('agenda').doc(turn.id).update({'estado': 'disponible', 'paciente': 'DISPONIBLE'});
               
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Turno cancelado y liberado.")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Sí, cancelar"),
          ),
        ],
      ),
    );
  }

  void _showAssignTurnBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Asignar Nuevo Turno", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
              const SizedBox(height: 10),
              const Text("Para esta demo, los turnos se crean desde 'Seed Data' o reservándolos como paciente.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2376F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Entendido", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTimelineColor(String status) {
    if (status == 'confirmado') return const Color(0xFF2376F6);
    if (status == 'atendido') return Colors.grey;
    if (status == 'en_consultorio') return Colors.green;
    if (status == 'disponible') return Colors.lightBlueAccent;
    return Colors.orange;
  }

  Color _getCardColor(String status) {
    if (status == 'atendido') return Colors.grey.withOpacity(0.05);
    if (status == 'disponible') return Colors.lightBlue.withOpacity(0.05);
    return Colors.white;
  }

  String amPm(String time) {
    final hour = int.tryParse(time.split(":")[0]) ?? 0;
    return hour >= 12 ? "PM" : "AM";
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

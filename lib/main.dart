import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculatrice(),
    ));

// ============================================================
// WIDGET 1 : zone d'affichage (résultat en grand + opération)
// ============================================================
class Ecran extends StatelessWidget {
  final String resultat;
  final String operation;

  const Ecran({super.key, required this.resultat, required this.operation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Résultat : grand format
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              resultat,
              style: const TextStyle(color: Colors.white, fontSize: 64),
            ),
          ),
          // Opération : petit format
          Text(
            operation,
            style: const TextStyle(color: Colors.white70, fontSize: 24),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET 2 : un bouton de la calculatrice
// ============================================================
class BoutonCalc extends StatelessWidget {
  final String texte;
  final Color couleur;
  final VoidCallback onTap;

  const BoutonCalc({
    super.key,
    required this.texte,
    required this.onTap,
    this.couleur = const Color(0xFF333333), // gris foncé par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: couleur,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: onTap,
          child: Text(texte, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET 3 : page principale (gère l'état avec setState)
// ============================================================
class Calculatrice extends StatefulWidget {
  const Calculatrice({super.key});

  @override
  State<Calculatrice> createState() => _CalculatriceState();
}

class _CalculatriceState extends State<Calculatrice> {
  String _saisie = '';    // nombre en cours de saisie
  double? _premier;       // premier nombre / résultat courant
  String _op = '';        // opérateur choisi
  String _resultat = '0'; // texte affiché en grand

  // Affiche un nombre sans ".0" inutile
  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  // Effectue : premier (op) saisie
  void _calculer() {
    if (_saisie.isEmpty) return;
    final b = double.parse(_saisie.endsWith('.') ? '${_saisie}0' : _saisie);

    if (_premier == null || _op.isEmpty) {
      _premier = b;
    } else if ((_op == '÷' || _op == '%') && b == 0) {
      _premier = null;
      _op = '';
      _saisie = '';
      _resultat = 'Erreur';
      return;
    } else {
      switch (_op) {
        case '+': _premier = _premier! + b; break;
        case '−': _premier = _premier! - b; break;
        case '×': _premier = _premier! * b; break;
        case '÷': _premier = _premier! / b; break;
        case '%': _premier = _premier! % b; break; // % = modulo (reste)
      }
    }
    _saisie = '';
    _resultat = _fmt(_premier!);
  }

  // Appelée à chaque appui sur un bouton
  void _appui(String t) {
    setState(() {
      if (t == 'C') {
        _saisie = '';
        _premier = null;
        _op = '';
        _resultat = '0';
      } else if ('0123456789'.contains(t)) {
        _saisie += t;
        _resultat = _saisie;
      } else if (t == '.') {
        if (!_saisie.contains('.')) _saisie += _saisie.isEmpty ? '0.' : '.';
        _resultat = _saisie;
      } else if (t == '=') {
        _calculer();
        _op = '';
      } else {
        // opérateur : + − × ÷ %
        if (_saisie.isEmpty && _premier == null) return;
        _calculer();
        _op = t;
      }
    });
  }

  // Construit une ligne de boutons à partir d'une liste de touches
  Widget _ligne(List<String> touches) {
    return Expanded(
      child: Row(
        children: touches.map((t) {
          return BoutonCalc(
            texte: t,
            couleur: t == '=' ? Colors.orange : const Color(0xFF333333),
            onTap: () => _appui(t),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Affichage
            Expanded(
              flex: 2,
              child: Ecran(
                resultat: _resultat,
                operation: _premier == null ? ' ' : '${_fmt(_premier!)} $_op',
              ),
            ),
            // Clavier
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _ligne(['C', '%', '÷', '×']),
                    _ligne(['7', '8', '9', '−']),
                    _ligne(['4', '5', '6', '+']),
                    _ligne(['1', '2', '3', '=']),
                    _ligne(['0', '.']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
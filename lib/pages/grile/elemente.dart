import 'package:flutter/material.dart';

/// Represents a menu item with an icon, title, and action.
class ElementeItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ElementeItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

/// Widget to display a single ElementeItem with fast single-tap responsiveness.
class ElementeItemWidget extends StatelessWidget {
  final ElementeItem item;

  const ElementeItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      splashColor: Colors.grey.withOpacity(0.2),
      highlightColor: Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        leading: Icon(
          item.icon,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
      ),
    );
  }
}

/// Widget to display the list of ElementeItems.
class ElementeList extends StatelessWidget {
  final Function(int) onTabSelected;

  const ElementeList({Key? key, required this.onTabSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final elements = Elemente.elements(context, onTabSelected);

    return ListView.builder(
      itemCount: elements.length,
      itemBuilder: (context, index) {
        return ElementeItemWidget(item: elements[index]);
      },
      padding: const EdgeInsets.symmetric(vertical: 8),
      physics: const BouncingScrollPhysics(),
    );
  }
}

/// Provides the complete list of elements available in the horizontal menu.
class Elemente {
  static List<ElementeItem> elements(BuildContext context, Function(int) onTabSelected) => [
        ElementeItem(
          icon: Icons.calendar_today,
          title: 'Planuri de învățat',
          onTap: () => onTabSelected(0),
        ),
        ElementeItem(
          icon: Icons.book,
          title: 'Teme',
          onTap: () => onTabSelected(1),
        ),
        ElementeItem(
          icon: Icons.quiz,
          title: 'Teste suplimentare',
          onTap: () => onTabSelected(2),
        ),
        ElementeItem(
          icon: Icons.merge_type,
          title: 'Teste combinate',
          onTap: () => onTabSelected(3),
        ),
        ElementeItem(
          icon: Icons.school,
          title: 'Simulări',
          onTap: () => onTabSelected(4),
        ),
        ElementeItem(
          icon: Icons.card_giftcard,
          title: 'Flashcards',
          onTap: () => onTabSelected(5),
        ),
        ElementeItem(
          icon: Icons.shuffle,
          title: 'Grile random',
          onTap: () => onTabSelected(6),
        ),
        ElementeItem(
          icon: Icons.date_range,
          title: 'Grile anii anteriori',
          onTap: () => onTabSelected(7),
        ),
        ElementeItem(
          icon: Icons.history,
          title: 'Istoric grile greșite',
          onTap: () => onTabSelected(8),
        ),
      ];
}
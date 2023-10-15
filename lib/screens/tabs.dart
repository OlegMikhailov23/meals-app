import 'package:flutter/material.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/screens/filters.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/widgets/main_drawer.dart';

import 'categories.dart';

const kInintialFilters = {
  MealsFilter.glutenFree: false,
  MealsFilter.lactoseFree: false,
  MealsFilter.vegan: false,
  MealsFilter.vegetarian: false,
};

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoritMeals = [];
  Map<MealsFilter, bool> _selectedFilters = kInintialFilters;

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleMealFavoriteStatus(Meal meal) {
    final isExisting = _favoritMeals.contains(meal);

    if (isExisting) {
      setState(() {
        _favoritMeals.remove(meal);
        _showInfoMessage('Meal is no longer a favorite!');
      });
    } else {
      setState(() {
        _favoritMeals.add(meal);
        _showInfoMessage('Meal in favorite now :)');
      });
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _setScreen(String id) async {
    Navigator.of(context).pop();
    if (id == 'filters') {
      final result = await Navigator.of(context)
          .push<Map<MealsFilter, bool>>(MaterialPageRoute(
              builder: (ctx) => FiltersScreen(
                    currentFilters: _selectedFilters,
                  )));
      print(result);

      setState(() {
        _selectedFilters = result ?? kInintialFilters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableMeals = dummyMeals.where((meal) {
      if (_selectedFilters[MealsFilter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (_selectedFilters[MealsFilter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (_selectedFilters[MealsFilter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      if (_selectedFilters[MealsFilter.vegan]! && !meal.isVegan) {
        return false;
      }
      return true;
    }).toList();

    Widget activePage = CategoriesScreen(
      onToggleFavorite: _toggleMealFavoriteStatus,
      availableMeals: availableMeals,
    );
    var activePageTitle = 'Categories';

    if (_selectedPageIndex == 1) {
      activePage = MealsScreen(
          meals: _favoritMeals, onToggleFavorite: _toggleMealFavoriteStatus);
      activePageTitle = 'Your Favorites';
    }

    return Scaffold(
      appBar: AppBar(title: Text(activePageTitle)),
      drawer: MainDrawer(
        onSelectScreen: _setScreen,
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.set_meal), label: "Categories"),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorites"),
          ]),
    );
  }
}

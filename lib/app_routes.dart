import 'package:flutter/material.dart';
import 'package:kltheguide/beyondkl.dart';
import 'package:kltheguide/ebook_page.dart';
import 'package:kltheguide/explorekl.dart';
import 'package:kltheguide/highlights.dart';
import 'package:kltheguide/medicaltourism.dart';
import 'package:kltheguide/shop.dart';
import 'package:kltheguide/spa.dart';
import 'package:kltheguide/stay.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/highlights-0': (context) => GlancePage(),
  '/highlights-1': (context) => GetAround(),
  '/highlights-2': (context) => const TravelTips(),
  '/rmd-0': (context) => ExploreKL(),
  '/explorekl-0': (context) => ExploreKL_WTD(),
  '/explorekl-1': (context) => const ExploreKL_HS2(),
  '/explorekl-2': (context) => const ExploreKL_PWOR2(),
  '/explorekl-3': (context) => const ExploreKL_WTE2(),
  '/explorekl-4': (context) => const ExploreKL_NL2(),
  '/explorekl-5': (context) => const ExploreKL_KL4K2(),
  '/explorekl-6': (context) => const ExploreKL_SS2(),
  '/explorekl-7': (context) => const ExploreKL_P2(),
  '/rmd-1': (context) => const Shop(),
  '/rmd-2': (context) => const Stay(),
  '/rmd-3': (context) => const Spa(),
  '/rmd-4': (context) => const MedicalT(),
  '/rmd-5': (context) => BeyondKL(),
  '/beyondkl-0': (context) => BeyondKL_I(),
  '/beyondkl-1': (context) => BeyondKL_HS(),
  '/beyondkl-2': (context) => BeyondKL_W(),
  '/beyondkl-3': (context) => BeyondKL_H(),
  '/beyondkl-4': (context) => BeyondKL_ES(),
  '/ebook-0': (context) =>
      const Ebook_view(category: 'kltg', name: 'KL The Guide'),
  '/ebook-1': (context) =>
      const Ebook_view(category: 'kv4l', name: 'Klang Valley 4 Locals'),
  '/ebook-2': (context) =>
      const Ebook_view(category: 'mktg', name: 'Melaka The Guide'),
  '/ebook-3': (context) =>
      const Ebook_view(category: 'tptg', name: 'Taiping The Guide'),
  '/ebook-4': (context) =>
      const Ebook_view(category: 'uztg', name: 'Uzbekistan The Guide'),
  '/ebook-5': (context) =>
      const Ebook_view(category: 'kntg', name: 'Keningau The Guide'),
  '/ebook-6': (context) =>
      const Ebook_view(category: 'twtg', name: 'Tawau The Guide'),
  '/ebook-7': (context) =>
      const Ebook_view(category: 'tbtg', name: 'Tambunan The Guide'),
  '/ebook-8': (context) =>
      const Ebook_view(category: 'hstg', name: 'Hulu Selangor The Guide'),
  '/ebook-9': (context) =>
      const Ebook_view(category: 'prtg', name: 'Perak The Guide'),
  '/ebook-10': (context) =>
      const Ebook_view(category: 'sbtg', name: 'Seremban The Guide'),
  '/ebook-11': (context) => const Ebook_view(
      category: 'kstg', name: 'Kuala Selangor The Guide'),
  '/ebook-12': (context) =>
      const Ebook_view(category: 'klgt', name: 'Kuala Langat The Guide'),
  '/ebook-13': (context) =>
      const Ebook_view(category: 'kztg', name: 'Kazakhstan The Guide'),
};

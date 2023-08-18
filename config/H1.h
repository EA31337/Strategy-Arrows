/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Arrows_Params_H1 : IndiArrowsParams {
  Indi_Arrows_Params_H1() : IndiArrowsParams(indi_arrows_defaults, PERIOD_H1) { shift = 0; }
} indi_arrows_h1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Arrows_Params_H1 : StgParams {
  // Struct constructor.
  Stg_Arrows_Params_H1() : StgParams(stg_arrows_defaults) {}
} stg_arrows_h1;

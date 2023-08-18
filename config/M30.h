/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Arrows_Params_M30 : IndiArrowsParams {
  Indi_Arrows_Params_M30() : IndiArrowsParams(indi_arrows_defaults, PERIOD_M30) { shift = 0; }
} indi_arrows_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Arrows_Params_M30 : StgParams {
  // Struct constructor.
  Stg_Arrows_Params_M30() : StgParams(stg_arrows_defaults) {}
} stg_arrows_m30;

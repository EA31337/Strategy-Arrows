/**
 * @file
 * Implements Arrows strategy based on the price-arrow-type indicators.
 */

// User input params.
INPUT_GROUP("Arrows strategy: strategy params");
INPUT float Arrows_LotSize = 0;                // Lot size
INPUT int Arrows_SignalOpenMethod = 0;         // Signal open method
INPUT float Arrows_SignalOpenLevel = 0;        // Signal open level
INPUT int Arrows_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int Arrows_SignalOpenFilterTime = 3;     // Signal open filter time (0-31)
INPUT int Arrows_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int Arrows_SignalCloseMethod = 0;        // Signal close method
INPUT int Arrows_SignalCloseFilter = 32;       // Signal close filter (-127-127)
INPUT float Arrows_SignalCloseLevel = 0;       // Signal close level
INPUT int Arrows_PriceStopMethod = 0;          // Price limit method
INPUT float Arrows_PriceStopLevel = 2;         // Price limit level
INPUT int Arrows_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT float Arrows_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT short Arrows_Shift = 0;                  // Shift
INPUT float Arrows_OrderCloseLoss = 80;        // Order close loss
INPUT float Arrows_OrderCloseProfit = 80;      // Order close profit
INPUT int Arrows_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Arrows strategy: Arrows indicator params");
INPUT int Arrows_Indi_Arrows_Shift = 0;                                        // Shift
INPUT ENUM_IDATA_SOURCE_TYPE Arrows_Indi_Arrows_SourceType = IDATA_INDICATOR;  // Source type

// Structs.

// Defines struct with default user strategy values.
struct Stg_Arrows_Params_Defaults : StgParams {
  Stg_Arrows_Params_Defaults()
      : StgParams(::Arrows_SignalOpenMethod, ::Arrows_SignalOpenFilterMethod, ::Arrows_SignalOpenLevel,
                  ::Arrows_SignalOpenBoostMethod, ::Arrows_SignalCloseMethod, ::Arrows_SignalCloseFilter,
                  ::Arrows_SignalCloseLevel, ::Arrows_PriceStopMethod, ::Arrows_PriceStopLevel,
                  ::Arrows_TickFilterMethod, ::Arrows_MaxSpread, ::Arrows_Shift) {
    Set(STRAT_PARAM_LS, Arrows_LotSize);
    Set(STRAT_PARAM_OCL, Arrows_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, Arrows_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, Arrows_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, Arrows_SignalOpenFilterTime);
  }
};

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_Arrows : public Strategy {
 public:
  Stg_Arrows(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Arrows *Init(ENUM_TIMEFRAMES _tf = NULL, EA *_ea = NULL) {
    // Initialize strategy initial values.
    Stg_Arrows_Params_Defaults stg_arrows_defaults;
    StgParams _stg_params(stg_arrows_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_arrows_m1, stg_arrows_m5, stg_arrows_m15, stg_arrows_m30,
                             stg_arrows_h1, stg_arrows_h4, stg_arrows_h8);
#endif
    // Initialize indicator.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Arrows(_stg_params, _tparams, _cparams, "Arrows");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    IndiArrowsParams _indi_params(::Arrows_Indi_Arrows_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_Arrows(_indi_params));
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level = 0.0f, int _shift = 0) {
    Indi_Arrows *_indi = GetIndicator();
    bool _result =
        _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        _result &= _indi.IsIncreasing(1, 0, _shift);
        _result &= _indi.IsIncByPct(_level / 10, 0, _shift, 2);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        _result &= _indi.IsDecreasing(1, 0, _shift);
        _result &= _indi.IsDecByPct(_level / 10, 0, _shift, 2);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};

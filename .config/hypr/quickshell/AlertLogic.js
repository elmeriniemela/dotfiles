.pragma library

// Pure transition logic so thresholds can be checked without changing real battery state.
function next(previous, available, plugged, percent, full) {
    const state = {low: previous.low, critical: previous.critical, full: previous.full};
    const alerts = [];
    if (!available) return {state: state, alerts: alerts};
    if (plugged) {
        state.low = false;
        state.critical = false;
        if (full && !state.full) alerts.push("full");
        state.full = full;
    } else {
        state.full = false;
        if (percent <= 5) {
            if (!state.critical) alerts.push("critical");
            state.critical = true;
            state.low = true;
        } else if (percent <= 15 && !state.low) {
            alerts.push("low");
            state.low = true;
        }
    }
    return {state: state, alerts: alerts};
}

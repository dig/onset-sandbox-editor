(function(obj) {
  ue.game = {};
  ue.game.callevent = function(name, ...args) {
    if (typeof name != "string") return;

    if (args.length == 0) {
      obj.callevent(name, "");
    }	else {
      let params = [];
      
      for (let i = 0; i < args.length; i++) {
        params[i] = args[i];
      }
      
      obj.callevent(name, JSON.stringify(params));
    }
  };
})(ue.game);
CallEvent = ue.game.callevent;

function OnDocumentReady(fn) {
  if (document.readyState === "complete" || document.readyState === "interactive") {
    setTimeout(fn, 1);
  } else {
    document.addEventListener("DOMContentLoaded", fn);
  }
} 
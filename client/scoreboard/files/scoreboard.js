function ResetScoreboard() {
  let table = document.getElementsByTagName('table')[0];
  table.getElementsByTagName("tbody")[0].innerHTML = table.rows[0].innerHTML;
}

function AddPlayer(name, kills, deaths, playtime, ping) {
  let table = document.getElementsByTagName('table')[0];
  let tableContent = table.getElementsByTagName("tbody")[0].innerHTML;

  table.getElementsByTagName("tbody")[0].innerHTML = tableContent + `<tr>
    <td>${name}</td>
    <td>${kills}</td>
    <td>${deaths}</td>
    <td>${SecondsToTime(playtime)}</td>
    <td>${ping}ms</td>
  </tr>`;
}

function SecondsToTime(d) {
  d = Number(d);
  var h = Math.floor(d / 3600);
  var m = Math.floor(d % 3600 / 60);
  var s = Math.floor(d % 3600 % 60);

  var hDisplay = h > 0 ? h + (h == 1 ? " hr, " : " hrs, ") : "";
  var mDisplay = m > 0 ? m + (m == 1 ? " min, " : " mins, ") : "";
  var sDisplay = s > 0 ? s + (s == 1 ? " sec" : " secs") : "";
  return hDisplay + mDisplay + sDisplay; 
}
const STATE = {
  OBJECTS: 'OBJECTS',
  VEHICLES: 'VEHICLES',
  WEAPONS: 'WEAPONS',
  CLOTHING: 'CLOTHING'
};

let state = {
  state : STATE.OBJECTS,
  objectLoaded : false,
  vehicleLoaded : false,
  weaponLoaded : false,
  clothingLoaded : false
};

function SetState(to) {
  let from = state.state;

  let arr = ['objects', 'vehicles', 'weapons', 'clothing'];
  for (let i = 0; i < arr.length; i++) {
    document.getElementById(arr[i]).classList.add('hidden');
    document.getElementById(`tab-${arr[i]}`).classList.remove('active');
  }

  switch (to) {
    case STATE.OBJECTS:
      document.getElementById('objects').classList.remove('hidden');
      document.getElementById('tab-objects').classList.add('active');
      break;
    case STATE.VEHICLES:
      document.getElementById('vehicles').classList.remove('hidden');
      document.getElementById('tab-vehicles').classList.add('active');
      break;
    case STATE.WEAPONS:
      document.getElementById('weapons').classList.remove('hidden');
      document.getElementById('tab-weapons').classList.add('active');
      break;
    case STATE.CLOTHING:
      document.getElementById('clothing').classList.remove('hidden');
      document.getElementById('tab-clothing').classList.add('active');
      break;
  }

  state.state = to;
}

DocReady(function() {
  document.getElementById('tab-objects').onclick = function() {
    SetState(STATE.OBJECTS);
  };

  document.getElementById('tab-vehicles').onclick = function() {
    SetState(STATE.VEHICLES);
  };

  document.getElementById('tab-weapons').onclick = function() {
    SetState(STATE.WEAPONS);
  };

  document.getElementById('tab-clothing').onclick = function() {
    SetState(STATE.CLOTHING);
  };
});

function Load(objectCount, vehicleCount, weaponCount, clothingCount) {
  LoadObjects(objectCount);
  LoadVehicles(vehicleCount);
  LoadWeapons(weaponCount);
  LoadClothing(clothingCount);
}

function LoadObjects(amount) {
  if (state.objectLoaded) return;
  state.objectLoaded = true;

  let listbox = document.getElementById('objects');

  let appendHTML = '';
  for (let i = 1; i < amount + 1; i++) {
    appendHTML += `<img data-id="${i}" src="http://game/objects/${i}" />`;
  }
  listbox.innerHTML += appendHTML;

  let nodes = listbox.getElementsByTagName('img');
  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];

    node.onclick = function() {
      CallEvent('CreateObjectPlacement', this.dataset.id);
    };
  }
}

function LoadVehicles(amount) {
  if (state.vehicleLoaded) return;
  state.vehicleLoaded = true;

  let listbox = document.getElementById('vehicles');

  let appendHTML = '';
  for (let i = 1; i < amount + 1; i++) {
    let modelID = 0;
    for (let key in VEHICLE_CONFIG) {
      let vehicleCfg = VEHICLE_CONFIG[key];

      if (vehicleCfg.vehicleID == i) {
        modelID = vehicleCfg.modelID;
        break;
      }
    }

    appendHTML += `<img data-id="${i}" src="http://game/objects/${modelID}" />`;
  }
  listbox.innerHTML += appendHTML;

  let nodes = listbox.getElementsByTagName('img');
  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];

    node.onclick = function() {
      CallEvent('CreateVehiclePlacement', this.dataset.id);
    };
  }
}

function LoadWeapons(amount) {
  if (state.weaponLoaded) return;
  state.weaponLoaded = true;

  let listbox = document.getElementById('weapons');

  let appendHTML = '';
  for (let i = 2; i < amount + 1; i++) {
    let modelID = 0;
    for (let key in WEAPON_CONFIG) {
      let weaponCfg = WEAPON_CONFIG[key];

      if (weaponCfg.weaponID == i) {
        modelID = weaponCfg.modelID;
        break;
      }
    }

    appendHTML += `<img data-objectid="${modelID}" data-weaponid="${i}" src="http://game/objects/${modelID}" />`;
  }
  listbox.innerHTML += appendHTML;

  let nodes = listbox.getElementsByTagName('img');
  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];

    node.onclick = function() {
      CallEvent('CreateWeaponPlacement', this.dataset.objectid, this.dataset.weaponid);
    };
  }
}

function LoadClothing(amount) {
  if (state.clothingLoaded) return;
  state.clothingLoaded = true;

  let listbox = document.getElementById('clothing');

  let appendHTML = '';
  for (let i = 1; i < amount + 1; i++) {
    appendHTML += `<img data-id="${i}" src="http://asset/sandbox/client/files/clothing/${(i == 11 ? 10 : i)}.jpg" />`;
  }
  listbox.innerHTML += appendHTML;

  let nodes = listbox.getElementsByTagName('img');
  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];

    node.onclick = function() {
      CallEvent('RequestClothingPreset', this.dataset.id);
    };
  }
}
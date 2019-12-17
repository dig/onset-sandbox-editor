const STATE = {
  OBJECTS: 'OBJECTS',
  VEHICLES: 'VEHICLES',
  WEAPONS: 'WEAPONS',
  DOORS: 'DOORS',
  CLOTHING: 'CLOTHING'
};

let state = {
  state : STATE.OBJECTS,
  objectLoaded : false,
  vehicleLoaded : false,
  weaponLoaded : false,
  doorLoaded : false,
  clothingLoaded : false
};

function SetState(to) {
  let from = state.state;

  let arr = ['objects', 'vehicles', 'weapons', 'doors', 'clothing'];
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
    case STATE.DOORS:
      document.getElementById('doors').classList.remove('hidden');
      document.getElementById('tab-doors').classList.add('active');
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

  document.getElementById('tab-doors').onclick = function() {
    SetState(STATE.DOORS);
  };

  document.getElementById('tab-clothing').onclick = function() {
    SetState(STATE.CLOTHING);
  };
});

function Load(objectCount, vehicleCount, weaponCount, clothingCount, doorCount) {
  LoadObjects(objectCount);
  LoadVehicles(vehicleCount);
  LoadWeapons(weaponCount);
  LoadDoors(doorCount);
  LoadClothing(clothingCount);
}

function LoadObjects(amount) {
  if (state.objectLoaded) return;
  state.objectLoaded = true;

  let listbox = document.getElementById('objects');

  let appendHTML = '';
  for (let i = 1; i < amount + 1; i++) {
    appendHTML += `<div class="item" data-id="${i}">
      <img src="http://game/objects/${i}" />
      <div class="top-left">${i}</div>
    </div>`;
  }
  listbox.innerHTML += appendHTML;

  let nodes = listbox.getElementsByClassName('item');
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

    appendHTML += `<div class="item" data-id="${i}">
      <img src="http://game/objects/${modelID}" />
      <div class="top-left">${i}</div>
    </div>`;
  }
  listbox.innerHTML += appendHTML;

  let nodes = listbox.getElementsByClassName('item');
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

    appendHTML += `<div class="item" data-objectid="${modelID}" data-weaponid="${i}">
      <img src="http://game/objects/${modelID}" />
      <div class="top-left">${i}</div>
    </div>`;
  }
  listbox.innerHTML += appendHTML;

  let nodes = listbox.getElementsByClassName('item');
  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];

    node.onclick = function() {
      CallEvent('CreateWeaponPlacement', this.dataset.objectid, this.dataset.weaponid);
    };
  }
}

function LoadDoors(amount) {
  if (state.doorLoaded) return;
  state.doorLoaded = true;

  let listbox = document.getElementById('doors');

  let appendHTML = '';
  for (let i = 1; i < amount + 1; i++) {
    let modelID = 0;
    let isCustom = false;

    for (let key in DOOR_CONFIG) {
      let doorCfg = DOOR_CONFIG[key];
      
      if (doorCfg.doorID == i) {
        modelID = doorCfg.modelID;
        isCustom = doorCfg.pictureID != null;
        break;
      }
    }

    appendHTML += `<div class="item" data-objectid="${modelID}" data-doorid="${i}">
      <img src="${(isCustom ? `http://asset/sandbox/client/editor/files/doors/${i}.jpg` : `http://game/objects/${modelID}`)}" />
      <div class="top-left">${i}</div>
    </div>`;
  }
  listbox.innerHTML += appendHTML;

  let nodes = listbox.getElementsByClassName('item');
  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];

    node.onclick = function() {
      CallEvent('CreateDoorPlacement', this.dataset.objectid, this.dataset.doorid);
    };
  }
}

function LoadClothing(amount) {
  if (state.clothingLoaded) return;
  state.clothingLoaded = true;

  let listbox = document.getElementById('clothing');

  let appendHTML = '';
  for (let i = 1; i < amount + 1; i++) {
    appendHTML += `<div class="item" data-id="${i}">
      <img src="http://asset/sandbox/client/editor/files/clothing/${(i == 11 ? 10 : i)}.jpg" />
      <div class="top-left">${i}</div>
    </div>`;
  }
  listbox.innerHTML += appendHTML;

  let nodes = listbox.getElementsByClassName('item');
  for (let i = 0; i < nodes.length; i++) {
    let node = nodes[i];

    node.onclick = function() {
      CallEvent('RequestClothingPreset', this.dataset.id);
    };
  }
}
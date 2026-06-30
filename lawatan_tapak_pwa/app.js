const DB_NAME = 'lawatan-tapak-db';
const DB_VERSION = 1;
const STORE_NAME = 'app';
const STATE_KEY = 'current-project';
const SESSION_AUTH_KEY = 'lawatanTapakAuthenticated';
const DEFAULT_LOGIN_CODE = '123456';

const photoCategories = [
  'Umum',
  'Kerja tanah',
  'Jalan',
  'Sistem saliran',
  'Retikulasi air',
  'Pembentungan'
];

const sentenceTemplates = {
  'site-ok': {
    observation: 'Keadaan semasa di lokasi ini telah direkodkan semasa lawatan tapak.',
    recommendation: ''
  },
  action: {
    observation: 'Pemerhatian menunjukkan terdapat perkara yang memerlukan tindakan lanjut di lokasi ini.',
    recommendation: 'Tindakan susulan dicadangkan bagi memastikan keadaan tapak berada dalam keadaan memuaskan.'
  },
  monitor: {
    observation: 'Lokasi ini perlu dipantau dari semasa ke semasa bagi mengenal pasti sebarang perubahan keadaan.',
    recommendation: 'Pemantauan berkala dicadangkan dan rekod bergambar perlu dikemaskini dalam lawatan seterusnya.'
  }
};

let state = createDefaultState();
let dbPromise;
let saveTimer;
let selectedPhotoId = null;
let deferredInstallPrompt = null;
let drawingSession = null;
let isAuthenticated = false;

const el = {
  loginScreen: byId('loginScreen'),
  loginForm: byId('loginForm'),
  loginCode: byId('loginCode'),
  logoutButton: byId('logoutButton'),
  storageStatus: byId('storageStatus'),
  installButton: byId('installButton'),
  installButtonPanel: byId('installButtonPanel'),
  statsGrid: byId('statsGrid'),
  photoGrid: byId('photoGrid'),
  photoNotice: byId('photoNotice'),
  cameraInput: byId('cameraInput'),
  galleryInput: byId('galleryInput'),
  cameraButton: byId('cameraButton'),
  galleryButton: byId('galleryButton'),
  demoButton: byId('demoButton'),
  visitGpsButton: byId('visitGpsButton'),
  mapBoard: byId('mapBoard'),
  mapList: byId('mapList'),
  mapFrame: byId('mapFrame'),
  routeLink: byId('routeLink'),
  printArea: byId('printArea'),
  printButton: byId('printButton'),
  downloadHtmlButton: byId('downloadHtmlButton'),
  exportJsonButton: byId('exportJsonButton'),
  exportJsonButton2: byId('exportJsonButton2'),
  importJsonButton: byId('importJsonButton'),
  importJsonInput: byId('importJsonInput'),
  currentLoginCode: byId('currentLoginCode'),
  newLoginCode: byId('newLoginCode'),
  confirmLoginCode: byId('confirmLoginCode'),
  changeLoginCodeButton: byId('changeLoginCodeButton')
};

const projectFields = [
  'projectName',
  'clientName',
  'locationName',
  'visitDate',
  'officerName',
  'weather',
  'levelOffset',
  'visitLatitude',
  'visitLongitude',
  'visitAltitude',
  'visitAccuracy',
  'visitLocationSource',
  'generalNotes',
  'conclusion'
];

document.addEventListener('DOMContentLoaded', init);

async function init() {
  bindNavigation();
  bindProjectForm();
  bindPhotoActions();
  bindReportActions();
  bindImportExport();
  bindInstall();
  bindAuthActions();
  registerServiceWorker();

  state = await loadState();
  normalizeState();
  selectedPhotoId = state.photos[0]?.id ?? null;
  hydrateProjectForm();
  renderAll();
  if (sessionStorage.getItem(SESSION_AUTH_KEY) === 'true') {
    unlockApp();
  } else {
    lockApp();
  }
  updateOnlineStatus();
  window.addEventListener('online', updateOnlineStatus);
  window.addEventListener('offline', updateOnlineStatus);
}

function byId(id) {
  return document.getElementById(id);
}

function createDefaultState() {
  return {
    version: 1,
    project: {
      projectName: 'Projek Lawatan Tapak',
      clientName: 'Nama Klien',
      locationName: 'Lokasi Tapak',
      visitDate: new Date().toISOString().slice(0, 10),
      officerName: 'Pegawai Tapak',
      weather: 'Cerah',
      levelOffset: 0,
      visitLatitude: null,
      visitLongitude: null,
      visitAltitude: null,
      visitAccuracy: null,
      visitVerticalAccuracy: null,
      visitLocationSource: 'Manual',
      visitGpsCapturedAt: null,
      generalNotes: 'Lawatan tapak dijalankan bagi merekod keadaan semasa.',
      conclusion: ''
    },
    security: {
      loginCode: DEFAULT_LOGIN_CODE
    },
    photos: []
  };
}

function normalizeState() {
  state.project = { ...createDefaultState().project, ...(state.project || {}) };
  state.security = {
    ...createDefaultState().security,
    ...(state.security || {})
  };
  state.security.loginCode = String(state.security.loginCode || DEFAULT_LOGIN_CODE);
  state.project.levelOffset = numberOrNull(state.project.levelOffset) ?? 0;
  state.project.visitLatitude = numberOrNull(state.project.visitLatitude);
  state.project.visitLongitude = numberOrNull(state.project.visitLongitude);
  state.project.visitAltitude = numberOrNull(state.project.visitAltitude);
  state.project.visitAccuracy = numberOrNull(state.project.visitAccuracy);
  state.project.visitVerticalAccuracy = numberOrNull(state.project.visitVerticalAccuracy);
  state.photos = Array.isArray(state.photos) ? state.photos : [];
  state.photos = state.photos.map((photo, index) => ({
    id: photo.id || createId('photo'),
    dataUrl: photo.dataUrl || '',
    fileName: photo.fileName || '',
    capturedAt: photo.capturedAt || new Date().toISOString(),
    latitude: numberOrNull(photo.latitude),
    longitude: numberOrNull(photo.longitude),
    altitude: numberOrNull(photo.altitude),
    adjustedLevel: numberOrNull(photo.adjustedLevel),
    horizontalAccuracy: numberOrNull(photo.horizontalAccuracy),
    verticalAccuracy: numberOrNull(photo.verticalAccuracy),
    locationSource: photo.locationSource || 'Manual',
    category: normalizeCategory(photo.category),
    caption: photo.caption || `Gambar ${index + 1}`,
    observation: photo.observation || '',
    recommendation: photo.recommendation || '',
    annotations: normalizeAnnotations(photo.annotations)
  }));
}

function bindNavigation() {
  document.querySelectorAll('.nav-button').forEach((button) => {
    button.addEventListener('click', () => {
      const target = button.dataset.view;
      document.querySelectorAll('.nav-button').forEach((item) => {
        item.classList.toggle('active', item === button);
      });
      document.querySelectorAll('.view').forEach((view) => {
        view.classList.toggle('active', view.id === target);
      });
      if (target === 'reportView') {
        renderReport();
      }
      if (target === 'mapView') {
        renderMap();
      }
    });
  });
}

function bindProjectForm() {
  projectFields.forEach((field) => {
    const input = byId(field);
    input.addEventListener('input', () => {
      const oldOffset = state.project.levelOffset;
      if (field === 'levelOffset') {
        state.project[field] = numberOrNull(input.value) ?? 0;
      } else if (numericProjectFields().includes(field)) {
        state.project[field] = numberOrNull(input.value);
      } else {
        state.project[field] = input.value;
      }

      if (field === 'levelOffset' && oldOffset !== state.project.levelOffset) {
        recalculateLevels();
        renderPhotos();
      }
      if (['visitLatitude', 'visitLongitude', 'visitAltitude'].includes(field)) {
        state.project.visitLocationSource = 'Manual';
        byId('visitLocationSource').value = state.project.visitLocationSource;
      }

      renderStats();
      renderMap();
      renderReport();
      saveDebounced();
    });
  });

  el.visitGpsButton.addEventListener('click', captureVisitGps);
}

function bindPhotoActions() {
  el.cameraButton.addEventListener('click', () => el.cameraInput.click());
  el.galleryButton.addEventListener('click', () => el.galleryInput.click());
  el.demoButton.addEventListener('click', addDemoPhoto);

  el.cameraInput.addEventListener('change', () => {
    handleFiles(el.cameraInput.files, 'camera');
    el.cameraInput.value = '';
  });

  el.galleryInput.addEventListener('change', () => {
    handleFiles(el.galleryInput.files, 'gallery');
    el.galleryInput.value = '';
  });
}

function bindReportActions() {
  el.printButton.addEventListener('click', () => {
    renderReport();
    document.body.classList.add('print-report');
    setTimeout(() => {
      window.print();
      document.body.classList.remove('print-report');
    }, 80);
  });

  el.downloadHtmlButton.addEventListener('click', () => {
    renderReport();
    downloadText(
      `laporan-lawatan-tapak-${dateStamp()}.html`,
      buildReportHtmlDocument(),
      'text/html'
    );
  });
}

function bindImportExport() {
  el.exportJsonButton.addEventListener('click', exportJson);
  el.exportJsonButton2.addEventListener('click', exportJson);
  el.importJsonButton.addEventListener('click', () => el.importJsonInput.click());
  el.importJsonInput.addEventListener('change', async () => {
    const file = el.importJsonInput.files?.[0];
    el.importJsonInput.value = '';
    if (!file) {
      return;
    }
    try {
      const imported = JSON.parse(await file.text());
      state = imported;
      normalizeState();
      selectedPhotoId = state.photos[0]?.id ?? null;
      hydrateProjectForm();
      renderAll();
      await saveState(state);
      toast('Data projek berjaya diimport.');
    } catch (error) {
      toast(`Data tidak dapat diimport: ${error.message}`);
    }
  });
}

function bindInstall() {
  window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    deferredInstallPrompt = event;
    el.installButton.hidden = false;
    el.installButtonPanel.disabled = false;
  });

  const install = async () => {
    if (!deferredInstallPrompt) {
      toast('Jika butang install tidak muncul, guna menu browser: Add to Home Screen atau Install app.');
      return;
    }
    deferredInstallPrompt.prompt();
    await deferredInstallPrompt.userChoice;
    deferredInstallPrompt = null;
    el.installButton.hidden = true;
  };

  el.installButton.addEventListener('click', install);
  el.installButtonPanel.addEventListener('click', install);
}

function bindAuthActions() {
  el.loginForm.addEventListener('submit', (event) => {
    event.preventDefault();
    const enteredCode = el.loginCode.value.trim();
    if (enteredCode === state.security.loginCode) {
      unlockApp();
      toast('Login berjaya.');
      return;
    }

    el.loginCode.select();
    toast('Login code tidak betul.');
  });

  el.logoutButton.addEventListener('click', () => {
    lockApp();
    toast('Anda telah logout.');
  });

  el.changeLoginCodeButton.addEventListener('click', changeLoginCode);
}

function unlockApp() {
  isAuthenticated = true;
  sessionStorage.setItem(SESSION_AUTH_KEY, 'true');
  document.body.classList.remove('auth-locked');
  el.loginCode.value = '';
}

function lockApp() {
  isAuthenticated = false;
  sessionStorage.removeItem(SESSION_AUTH_KEY);
  document.body.classList.add('auth-locked');
  setTimeout(() => el.loginCode.focus(), 50);
}

function changeLoginCode() {
  const currentCode = el.currentLoginCode.value.trim();
  const newCode = el.newLoginCode.value.trim();
  const confirmCode = el.confirmLoginCode.value.trim();

  if (currentCode !== state.security.loginCode) {
    toast('Code semasa tidak betul.');
    return;
  }

  if (newCode.length < 4) {
    toast('Code baru mesti sekurang-kurangnya 4 aksara.');
    return;
  }

  if (newCode !== confirmCode) {
    toast('Sahkan code baru tidak sama.');
    return;
  }

  state.security.loginCode = newCode;
  el.currentLoginCode.value = '';
  el.newLoginCode.value = '';
  el.confirmLoginCode.value = '';
  saveDebounced();
  toast('Login code berjaya ditukar.');
}

async function handleFiles(fileList, mode) {
  const files = Array.from(fileList || []).filter((file) => file.type.startsWith('image/'));
  if (!files.length) {
    return;
  }

  setBusy(true, `Mencari GPS terbaik untuk ${files.length} gambar...`);
  let currentPosition = null;
  try {
    currentPosition = await getBestPosition();
  } catch (_) {
    currentPosition = null;
  }

  try {
    for (const file of files) {
      const photo = await createPhotoFromFile(file, mode, currentPosition);
      state.photos.push(photo);
      selectedPhotoId = photo.id;
    }
    await saveState(state);
    renderAll();
    toast(`${files.length} gambar berjaya ditambah.`);
  } catch (error) {
    toast(`Gambar tidak dapat diproses: ${error.message}`);
  } finally {
    setBusy(false);
  }
}

async function createPhotoFromFile(file, mode, currentPosition) {
  const [dataUrl, exif] = await Promise.all([
    resizeImage(file),
    readExifGps(file)
  ]);

  const hasExifCoordinate = isFiniteNumber(exif?.latitude) && isFiniteNumber(exif?.longitude);
  const position = currentPosition?.coords;
  const latitude = hasExifCoordinate ? exif.latitude : numberOrNull(position?.latitude);
  const longitude = hasExifCoordinate ? exif.longitude : numberOrNull(position?.longitude);
  const altitude = numberOrNull(exif?.altitude) ?? numberOrNull(position?.altitude);
  const source = hasExifCoordinate
    ? 'EXIF gambar'
    : position
      ? `GPS ketepatan tinggi (${formatAccuracy(position.accuracy ?? position.coords?.accuracy)})`
      : 'Manual';

  return {
    id: createId('photo'),
    dataUrl,
    fileName: file.name,
    capturedAt: exif?.capturedAt || new Date().toISOString(),
    latitude,
    longitude,
    altitude,
    adjustedLevel: altitude == null ? null : altitude + state.project.levelOffset,
    horizontalAccuracy: numberOrNull(position?.accuracy),
    verticalAccuracy: numberOrNull(position?.altitudeAccuracy),
    locationSource: mode === 'camera' && source.startsWith('GPS ketepatan tinggi') ? `GPS kamera ${source.replace('GPS ', '')}` : source,
    category: 'Kerja tanah',
    caption: file.name ? file.name.replace(/\.[^.]+$/, '') : `Gambar ${state.photos.length + 1}`,
    observation: '',
    recommendation: '',
    annotations: []
  };
}

function addDemoPhoto() {
  const count = state.photos.length;
  const altitude = 42.5 + count;
  const demo = {
    id: createId('photo'),
    dataUrl: '',
    fileName: '',
    capturedAt: new Date().toISOString(),
    latitude: 3.139003 + count * 0.00018,
    longitude: 101.686855 + count * 0.00022,
    altitude,
    adjustedLevel: altitude + state.project.levelOffset,
    horizontalAccuracy: 8,
    verticalAccuracy: 12,
    locationSource: 'Demo',
    category: photoCategories[count % photoCategories.length],
    caption: `Contoh gambar ${count + 1}`,
    observation: 'Keadaan tapak direkodkan semasa lawatan.',
    recommendation: 'Semakan lanjut boleh dibuat jika perlu.',
    annotations: []
  };
  state.photos.push(demo);
  selectedPhotoId = demo.id;
  renderAll();
  saveDebounced();
}

function hydrateProjectForm() {
  projectFields.forEach((field) => {
    const input = byId(field);
    input.value = state.project[field] ?? '';
  });
}

function renderAll() {
  renderStats();
  renderPhotos();
  renderMap();
  renderReport();
}

function renderStats() {
  const total = state.photos.length;
  const withCoordinate = state.photos.filter(hasCoordinate).length;
  const withAltitude = state.photos.filter((photo) => isFiniteNumber(photo.altitude)).length;
  const offset = state.project.levelOffset || 0;
  el.statsGrid.innerHTML = [
    statCard('Jumlah gambar', total),
    statCard('Ada koordinat', withCoordinate),
    statCard('Ada altitude', withAltitude),
    statCard('Offset level', `${formatNumber(offset, 3)} m`),
    statCard('Akurasi GPS lawatan', formatAccuracy(state.project.visitAccuracy))
  ].join('');
}

function renderPhotos() {
  el.photoGrid.innerHTML = '';
  if (!state.photos.length) {
    el.photoGrid.innerHTML = '<div class="notice">Belum ada gambar. Ambil gambar, import daripada galeri atau tambah demo.</div>';
    return;
  }

  const template = byId('photoCardTemplate');
  state.photos.forEach((photo, index) => {
    const node = template.content.firstElementChild.cloneNode(true);
    const media = node.querySelector('.photo-media');
    const title = node.querySelector('h3');
    const mapsLink = node.querySelector('.small-link');

    title.textContent = photo.caption || `Gambar ${index + 1}`;
    mapsLink.href = hasCoordinate(photo) ? googleSearchUrl(photo) : 'https://www.google.com/maps';
    mapsLink.toggleAttribute('hidden', !hasCoordinate(photo));

    if (photo.dataUrl) {
      const image = document.createElement('img');
      image.alt = photo.caption || `Gambar ${index + 1}`;
      image.src = photo.dataUrl;
      media.appendChild(image);
    } else {
      const placeholder = document.createElement('span');
      placeholder.textContent = 'Tiada imej demo';
      media.appendChild(placeholder);
    }
    media.insertAdjacentHTML('beforeend', annotationSvg(photo));
    media.addEventListener('pointerdown', (event) => startAnnotationDraw(photo.id, node, media, event));
    media.addEventListener('pointermove', (event) => updateAnnotationDraw(media, event));
    media.addEventListener('pointerup', (event) => finishAnnotationDraw(media, event));
    media.addEventListener('pointercancel', () => cancelAnnotationDraw(media));

    node.querySelectorAll('[data-field]').forEach((input) => {
      const field = input.dataset.field;
      input.value = valueForInput(photo[field]);
      input.addEventListener('input', () => {
        updatePhotoField(photo.id, field, input.value, input);
        title.textContent = findPhoto(photo.id)?.caption || `Gambar ${index + 1}`;
      });
    });

    node.querySelectorAll('[data-sentence]').forEach((button) => {
      button.addEventListener('click', () => appendSentence(photo.id, button.dataset.sentence));
    });

    node.querySelector('[data-refresh-gps]').addEventListener('click', () => refreshPhotoGps(photo.id));
    node.querySelector('[data-undo-annotation]').addEventListener('click', () => undoAnnotation(photo.id));
    node.querySelector('[data-clear-annotations]').addEventListener('click', () => clearAnnotations(photo.id));
    el.photoGrid.appendChild(node);
  });
}

function renderMap() {
  const located = state.photos.filter(hasCoordinate);
  const visitLocation = getVisitLocation();
  const mapPoints = visitLocation ? [visitLocation, ...located] : located;
  el.mapBoard.innerHTML = '';
  el.mapList.innerHTML = '';

  if (!mapPoints.length) {
    el.mapBoard.innerHTML = '<div class="map-empty">Belum ada GPS lawatan atau gambar dengan koordinat. Ambil GPS lawatan, ambil GPS semasa gambar atau isi latitude dan longitude secara manual.</div>';
    el.routeLink.href = 'https://www.google.com/maps';
    el.mapFrame.removeAttribute('src');
    return;
  }

  if (!selectedPhotoId || !located.some((photo) => photo.id === selectedPhotoId)) {
    selectedPhotoId = located[0]?.id ?? 'visit-location';
  }

  const bounds = getBounds(mapPoints);
  if (visitLocation) {
    const visitMarker = document.createElement('button');
    visitMarker.className = `map-marker visit-marker${selectedPhotoId === 'visit-location' ? ' active' : ''}`;
    visitMarker.style.left = `${projectLongitude(visitLocation.longitude, bounds)}%`;
    visitMarker.style.top = `${projectLatitude(visitLocation.latitude, bounds)}%`;
    visitMarker.title = 'GPS lokasi lawatan';
    visitMarker.type = 'button';
    visitMarker.innerHTML = '<span>L</span>';
    visitMarker.addEventListener('click', () => {
      selectedPhotoId = 'visit-location';
      renderMap();
    });
    el.mapBoard.appendChild(visitMarker);
  }

  located.forEach((photo) => {
    const marker = document.createElement('button');
    marker.className = `map-marker${photo.id === selectedPhotoId ? ' active' : ''}`;
    marker.style.left = `${projectLongitude(photo.longitude, bounds)}%`;
    marker.style.top = `${projectLatitude(photo.latitude, bounds)}%`;
    marker.title = photo.caption || 'Gambar tapak';
    marker.type = 'button';
    marker.innerHTML = `<span>${state.photos.indexOf(photo) + 1}</span>`;
    marker.addEventListener('click', () => {
      selectedPhotoId = photo.id;
      renderMap();
    });
    el.mapBoard.appendChild(marker);
  });

  if (visitLocation) {
    const visitButton = document.createElement('button');
    visitButton.className = 'map-list-item';
    visitButton.type = 'button';
    visitButton.innerHTML = `
      <strong>Lokasi lawatan</strong>
      <span>${formatCoordinate(visitLocation)} | Akurasi ${formatAccuracy(state.project.visitAccuracy)}</span>
    `;
    visitButton.addEventListener('click', () => {
      selectedPhotoId = 'visit-location';
      renderMap();
    });
    el.mapList.appendChild(visitButton);
  }

  located.forEach((photo) => {
    const button = document.createElement('button');
    button.className = 'map-list-item';
    button.type = 'button';
    button.innerHTML = `
      <strong>${escapeHtml(photo.caption || 'Gambar tapak')}</strong>
      <span>${formatCoordinate(photo)} | ${formatLevel(photo)}</span>
    `;
    button.addEventListener('click', () => {
      selectedPhotoId = photo.id;
      renderMap();
    });
    el.mapList.appendChild(button);
  });

  const selected = selectedPhotoId === 'visit-location'
    ? visitLocation
    : findPhoto(selectedPhotoId) || located[0] || visitLocation;
  el.mapFrame.src = googleEmbedUrl(selected);
  el.routeLink.href = googleDirectionsUrl(mapPoints);
}

function renderReport() {
  const photos = state.photos;
  const project = state.project;
  const rows = photos.map((photo, index) => `
    <tr>
      <td>${index + 1}</td>
      <td>${escapeHtml(photo.caption || '-')}</td>
      <td>${escapeHtml(photo.category || '-')}</td>
      <td>${escapeHtml(formatCoordinate(photo))}</td>
      <td>${escapeHtml(formatLevel(photo))}</td>
      <td>${escapeHtml(photo.observation || '-')}</td>
    </tr>
  `).join('');

  const photoBlocks = photos.map((photo, index) => `
    <section class="report-photo">
      <h3>Gambar ${index + 1}: ${escapeHtml(photo.caption || 'Gambar tapak')}</h3>
      ${reportImageHtml(photo, index)}
      <table class="report-meta">
        <tr><th>Koordinat</th><td>${escapeHtml(formatCoordinate(photo))}</td></tr>
        <tr><th>Altitude</th><td>${escapeHtml(formatAltitude(photo))}</td></tr>
        <tr><th>Adjusted level</th><td>${escapeHtml(formatLevel(photo))}</td></tr>
        <tr><th>Akurasi horizontal</th><td>${escapeHtml(formatAccuracy(photo.horizontalAccuracy))}</td></tr>
        <tr><th>Sumber lokasi</th><td>${escapeHtml(photo.locationSource || '-')}</td></tr>
      </table>
      ${photo.observation ? `<p><strong>Pemerhatian:</strong> ${escapeHtml(photo.observation)}</p>` : ''}
      ${photo.recommendation ? `<p><strong>Cadangan:</strong> ${escapeHtml(photo.recommendation)}</p>` : ''}
      ${hasCoordinate(photo) ? `<p><a href="${googleSearchUrl(photo)}" target="_blank" rel="noreferrer">Buka lokasi di Google Maps</a></p>` : ''}
    </section>
  `).join('');

  el.printArea.innerHTML = `
    <header class="report-cover">
      <h1>Laporan Lawatan Tapak</h1>
      <p><strong>${escapeHtml(project.projectName || '')}</strong></p>
      <p>${escapeHtml(project.locationName || '')}</p>
    </header>

    <h2>Maklumat projek</h2>
    <table class="report-meta">
      <tr><th>Klien</th><td>${escapeHtml(project.clientName || '')}</td></tr>
      <tr><th>Tarikh lawatan</th><td>${escapeHtml(project.visitDate || '')}</td></tr>
      <tr><th>Pegawai</th><td>${escapeHtml(project.officerName || '')}</td></tr>
      <tr><th>Cuaca</th><td>${escapeHtml(project.weather || '')}</td></tr>
      <tr><th>Offset level</th><td>${formatNumber(project.levelOffset, 3)} m</td></tr>
      <tr><th>GPS lawatan</th><td>${escapeHtml(hasVisitCoordinate() ? formatCoordinate(getVisitLocation()) : 'Belum direkod')}</td></tr>
      <tr><th>Altitude lawatan</th><td>${escapeHtml(formatAltitude(getVisitLocation() || {}))}</td></tr>
      <tr><th>Akurasi GPS lawatan</th><td>${escapeHtml(formatAccuracy(project.visitAccuracy))}</td></tr>
      <tr><th>Sumber lokasi lawatan</th><td>${escapeHtml(project.visitLocationSource || '-')}</td></tr>
    </table>

    ${project.generalNotes ? `<h2>Catatan umum</h2><p>${escapeHtml(project.generalNotes)}</p>` : ''}

    <h2>Jadual gambar</h2>
    <table class="report-table">
      <thead>
        <tr>
          <th>No.</th>
          <th>Gambar</th>
          <th>Kategori</th>
          <th>Koordinat</th>
          <th>Level</th>
          <th>Pemerhatian</th>
        </tr>
      </thead>
      <tbody>${rows || '<tr><td colspan="6">Belum ada gambar.</td></tr>'}</tbody>
    </table>

    <h2>Lampiran gambar</h2>
    ${photoBlocks || '<p>Belum ada gambar untuk laporan.</p>'}

    ${project.conclusion ? `<h2>Kesimpulan</h2><p>${escapeHtml(project.conclusion)}</p>` : ''}
  `;
}

function reportImageHtml(photo, index) {
  if (!photo.dataUrl) {
    return `
      <div class="report-image-wrap">
        <div class="map-empty">Imej demo / tiada fail imej.</div>
        ${annotationSvg(photo)}
      </div>`;
  }

  return `
    <div class="report-image-wrap">
      <img src="${photo.dataUrl}" alt="${escapeHtml(photo.caption || `Gambar ${index + 1}`)}">
      ${annotationSvg(photo)}
    </div>`;
}

function updatePhotoField(id, field, rawValue, input) {
  const photo = findPhoto(id);
  if (!photo) {
    return;
  }

  if (['latitude', 'longitude', 'altitude', 'adjustedLevel'].includes(field)) {
    photo[field] = numberOrNull(rawValue);
    if (field === 'altitude') {
      photo.adjustedLevel = photo.altitude == null
        ? null
        : photo.altitude + state.project.levelOffset;
      const adjustedInput = input.closest('.photo-card').querySelector('[data-field="adjustedLevel"]');
      adjustedInput.value = valueForInput(photo.adjustedLevel);
    }
  } else {
    photo[field] = rawValue;
  }

  if (field === 'latitude' || field === 'longitude') {
    photo.locationSource = 'Manual';
  }

  renderStats();
  renderMap();
  renderReport();
  saveDebounced();
}

function appendSentence(id, key) {
  const photo = findPhoto(id);
  const template = sentenceTemplates[key];
  if (!photo || !template) {
    return;
  }
  if (template.observation) {
    photo.observation = joinSentences(photo.observation, template.observation);
  }
  if (template.recommendation) {
    photo.recommendation = joinSentences(photo.recommendation, template.recommendation);
  }
  renderPhotos();
  renderReport();
  saveDebounced();
}

function startAnnotationDraw(photoId, cardNode, media, event) {
  if (!event.isPrimary || (event.button !== undefined && event.button !== 0)) {
    return;
  }

  const photo = findPhoto(photoId);
  if (!photo) {
    return;
  }

  event.preventDefault();
  const point = pointerPercent(media, event);
  drawingSession = {
    photoId,
    pointerId: event.pointerId,
    type: cardNode.querySelector('[data-annotation-type]').value,
    color: cardNode.querySelector('[data-annotation-color]').value || '#e11d48',
    text: cardNode.querySelector('[data-annotation-text]').value.trim(),
    startX: point.x,
    startY: point.y,
    endX: point.x,
    endY: point.y
  };

  if (media.setPointerCapture) {
    media.setPointerCapture(event.pointerId);
  }

  renderAnnotationLayer(media, photo, annotationFromDrawing(drawingSession, true));
}

function updateAnnotationDraw(media, event) {
  if (!drawingSession || drawingSession.pointerId !== event.pointerId) {
    return;
  }

  event.preventDefault();
  const photo = findPhoto(drawingSession.photoId);
  if (!photo) {
    return;
  }

  const point = pointerPercent(media, event);
  drawingSession.endX = point.x;
  drawingSession.endY = point.y;
  renderAnnotationLayer(media, photo, annotationFromDrawing(drawingSession, true));
}

function finishAnnotationDraw(media, event) {
  if (!drawingSession || drawingSession.pointerId !== event.pointerId) {
    return;
  }

  event.preventDefault();
  const session = drawingSession;
  drawingSession = null;

  if (media.releasePointerCapture) {
    media.releasePointerCapture(event.pointerId);
  }

  const photo = findPhoto(session.photoId);
  if (!photo) {
    return;
  }

  if (drawDistance(session) < 2.5) {
    renderAnnotationLayer(media, photo);
    toast('Tarik lebih panjang untuk lukis markup.');
    return;
  }

  photo.annotations = normalizeAnnotations(photo.annotations);
  photo.annotations.push(annotationFromDrawing(session, false));
  renderPhotos();
  renderReport();
  saveDebounced();
}

function cancelAnnotationDraw(media) {
  if (!drawingSession) {
    return;
  }

  const photo = findPhoto(drawingSession.photoId);
  drawingSession = null;
  if (photo) {
    renderAnnotationLayer(media, photo);
  }
}

function undoAnnotation(photoId) {
  const photo = findPhoto(photoId);
  if (!photo) {
    return;
  }

  photo.annotations = normalizeAnnotations(photo.annotations);
  photo.annotations.pop();
  renderPhotos();
  renderReport();
  saveDebounced();
}

function renderAnnotationLayer(media, photo, previewAnnotation = null) {
  const existing = media.querySelector('.annotation-svg');
  if (existing) {
    existing.outerHTML = annotationSvg(photo, previewAnnotation);
  } else {
    media.insertAdjacentHTML('beforeend', annotationSvg(photo, previewAnnotation));
  }
}

function annotationFromDrawing(session, preview) {
  return {
    id: preview ? 'preview-mark' : createId('mark'),
    type: session.type === 'circle' ? 'circle' : 'arrow',
    color: sanitizeColor(session.color),
    text: session.text,
    startX: clamp(session.startX, 0, 100),
    startY: clamp(session.startY, 0, 100),
    endX: clamp(session.endX, 0, 100),
    endY: clamp(session.endY, 0, 100),
    preview
  };
}

function pointerPercent(media, event) {
  const rect = media.getBoundingClientRect();
  return {
    x: clamp(((event.clientX - rect.left) / rect.width) * 100, 0, 100),
    y: clamp(((event.clientY - rect.top) / rect.height) * 100, 0, 100)
  };
}

function drawDistance(session) {
  return Math.hypot(session.endX - session.startX, session.endY - session.startY);
}

function clearAnnotations(photoId) {
  const photo = findPhoto(photoId);
  if (!photo) {
    return;
  }
  photo.annotations = [];
  renderPhotos();
  renderReport();
  saveDebounced();
}

function annotationSvg(photo, previewAnnotation = null) {
  const annotations = previewAnnotation
    ? [...normalizeAnnotations(photo.annotations), previewAnnotation]
    : normalizeAnnotations(photo.annotations);
  if (!annotations.length) {
    return '<svg class="annotation-svg" viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true"></svg>';
  }

  const content = annotations.map((annotation) => {
    if (annotation.type === 'circle') {
      return circleAnnotationSvg(annotation);
    }
    return arrowAnnotationSvg(annotation);
  }).join('');

  return `<svg class="annotation-svg" viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true">${content}</svg>`;
}

function arrowAnnotationSvg(annotation) {
  const color = sanitizeColor(annotation.color);
  const x1 = annotation.startX;
  const y1 = annotation.startY;
  const x2 = annotation.endX;
  const y2 = annotation.endY;
  const angle = Math.atan2(y2 - y1, x2 - x1);
  const headLength = 5;
  const headWidth = 3.2;
  const leftX = x2 - headLength * Math.cos(angle) + headWidth * Math.sin(angle);
  const leftY = y2 - headLength * Math.sin(angle) - headWidth * Math.cos(angle);
  const rightX = x2 - headLength * Math.cos(angle) - headWidth * Math.sin(angle);
  const rightY = y2 - headLength * Math.sin(angle) + headWidth * Math.cos(angle);
  const labelX = (x1 + x2) / 2;
  const labelY = (y1 + y2) / 2 - 5;
  const opacity = annotation.preview ? '0.72' : '1';
  const label = annotation.text ? `
    <text x="${formatNumber(labelX, 2)}" y="${formatNumber(labelY, 2)}" text-anchor="middle" dominant-baseline="central"
      font-size="4.2" font-weight="700" fill="${color}" stroke="#ffffff" stroke-width="0.7" paint-order="stroke">
      ${escapeSvg(annotation.text.slice(0, 24))}
    </text>` : '';

  return `
    <g opacity="${opacity}">
      <line x1="${formatNumber(x1, 2)}" y1="${formatNumber(y1, 2)}" x2="${formatNumber(x2, 2)}" y2="${formatNumber(y2, 2)}"
        stroke="${color}" stroke-width="2.8" stroke-linecap="round"></line>
      <polygon points="${formatNumber(x2, 2)},${formatNumber(y2, 2)} ${formatNumber(leftX, 2)},${formatNumber(leftY, 2)} ${formatNumber(rightX, 2)},${formatNumber(rightY, 2)}" fill="${color}"></polygon>
      ${label}
    </g>`;
}

function circleAnnotationSvg(annotation) {
  const color = sanitizeColor(annotation.color);
  const text = escapeSvg(annotation.text.slice(0, 26));
  const centerX = (annotation.startX + annotation.endX) / 2;
  const centerY = (annotation.startY + annotation.endY) / 2;
  const radius = Math.max(
    Math.abs(annotation.endX - annotation.startX),
    Math.abs(annotation.endY - annotation.startY),
    4
  ) / 2;
  const opacity = annotation.preview ? '0.72' : '1';
  return `
    <g opacity="${opacity}">
      <circle cx="${formatNumber(centerX, 2)}" cy="${formatNumber(centerY, 2)}" r="${formatNumber(radius, 2)}"
        fill="${hexToRgba(color, 0.18)}" stroke="${color}" stroke-width="2.2"></circle>
      ${text ? `<text x="${formatNumber(centerX, 2)}" y="${formatNumber(centerY, 2)}"
        text-anchor="middle" dominant-baseline="central" font-size="3.8" font-weight="700"
        fill="${color}" stroke="#ffffff" stroke-width="0.6" paint-order="stroke">${text}</text>` : ''}
    </g>`;
}

async function refreshPhotoGps(id) {
  const photo = findPhoto(id);
  if (!photo) {
    return;
  }
  setBusy(true, 'Mendapatkan GPS paling tepat...');
  try {
    const position = await getBestPosition();
    photo.latitude = numberOrNull(position.coords.latitude);
    photo.longitude = numberOrNull(position.coords.longitude);
    photo.altitude = numberOrNull(position.coords.altitude);
    photo.horizontalAccuracy = numberOrNull(position.coords.accuracy);
    photo.verticalAccuracy = numberOrNull(position.coords.altitudeAccuracy);
    photo.adjustedLevel = photo.altitude == null ? null : photo.altitude + state.project.levelOffset;
    photo.locationSource = `GPS ketepatan tinggi (${formatAccuracy(position.coords.accuracy)})`;
    selectedPhotoId = photo.id;
    renderAll();
    saveDebounced();
    toast(`GPS terbaik berjaya disimpan pada gambar. Akurasi: ${formatAccuracy(position.coords.accuracy)}.`);
  } catch (error) {
    toast(`GPS tidak dapat diperoleh: ${error.message}`);
  } finally {
    setBusy(false);
  }
}

function recalculateLevels() {
  state.photos.forEach((photo) => {
    photo.adjustedLevel = photo.altitude == null
      ? null
      : photo.altitude + state.project.levelOffset;
  });
}

function findPhoto(id) {
  return state.photos.find((photo) => photo.id === id);
}

function hasCoordinate(photo) {
  return isFiniteNumber(photo.latitude) && isFiniteNumber(photo.longitude);
}

function hasVisitCoordinate() {
  return isFiniteNumber(state.project.visitLatitude) && isFiniteNumber(state.project.visitLongitude);
}

function getVisitLocation() {
  if (!hasVisitCoordinate()) {
    return null;
  }
  return {
    id: 'visit-location',
    caption: 'Lokasi lawatan',
    latitude: state.project.visitLatitude,
    longitude: state.project.visitLongitude,
    altitude: state.project.visitAltitude,
    adjustedLevel: state.project.visitAltitude == null
      ? null
      : state.project.visitAltitude + state.project.levelOffset,
    locationSource: state.project.visitLocationSource || 'Manual',
    observation: '',
    recommendation: '',
    annotations: []
  };
}

async function captureVisitGps() {
  setBusy(true, 'Mendapatkan GPS lawatan paling tepat...');
  try {
    const position = await getBestPosition();
    state.project.visitLatitude = numberOrNull(position.coords.latitude);
    state.project.visitLongitude = numberOrNull(position.coords.longitude);
    state.project.visitAltitude = numberOrNull(position.coords.altitude);
    state.project.visitAccuracy = numberOrNull(position.coords.accuracy);
    state.project.visitVerticalAccuracy = numberOrNull(position.coords.altitudeAccuracy);
    state.project.visitLocationSource = `GPS ketepatan tinggi (${formatAccuracy(position.coords.accuracy)})`;
    state.project.visitGpsCapturedAt = new Date().toISOString();
    hydrateProjectForm();
    renderAll();
    saveDebounced();
    toast(`GPS lawatan disimpan. Akurasi: ${formatAccuracy(position.coords.accuracy)}.`);
  } catch (error) {
    toast(`GPS lawatan tidak dapat diperoleh: ${error.message}`);
  } finally {
    setBusy(false);
  }
}

function getBestPosition(options = {}) {
  const timeoutMs = options.timeoutMs ?? 20000;
  const targetAccuracyMeters = options.targetAccuracyMeters ?? 5;

  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocation tidak disokong oleh browser ini.'));
      return;
    }

    let bestPosition = null;
    let settled = false;
    let watchId = null;

    const finish = (error) => {
      if (settled) {
        return;
      }
      settled = true;
      clearTimeout(timer);
      if (watchId !== null) {
        navigator.geolocation.clearWatch(watchId);
      }
      if (bestPosition) {
        resolve(bestPosition);
      } else {
        reject(error || new Error('GPS tidak memberi bacaan.'));
      }
    };

    const timer = setTimeout(() => {
      finish(new Error('GPS mengambil masa terlalu lama.'));
    }, timeoutMs);

    watchId = navigator.geolocation.watchPosition((position) => {
      if (!bestPosition || positionScore(position) < positionScore(bestPosition)) {
        bestPosition = position;
      }

      if (isFiniteNumber(position.coords.accuracy) &&
          position.coords.accuracy <= targetAccuracyMeters) {
        finish();
      }
    }, (error) => {
      finish(new Error(locationErrorMessage(error)));
    }, {
      enableHighAccuracy: true,
      timeout: timeoutMs,
      maximumAge: 0
    });
  });
}

function positionScore(position) {
  const accuracy = numberOrNull(position?.coords?.accuracy) ?? 999999;
  const altitudeAccuracy = numberOrNull(position?.coords?.altitudeAccuracy) ?? 200;
  return accuracy + altitudeAccuracy * 0.2;
}

function locationErrorMessage(error) {
  if (!error) {
    return 'GPS tidak tersedia.';
  }
  if (error.code === 1) {
    return 'Permission lokasi tidak dibenarkan.';
  }
  if (error.code === 2) {
    return 'Lokasi tidak tersedia pada peranti ini.';
  }
  if (error.code === 3) {
    return 'GPS timeout sebelum bacaan diterima.';
  }
  return error.message || 'GPS tidak tersedia.';
}

async function resizeImage(file) {
  const objectUrl = URL.createObjectURL(file);
  try {
    const image = await loadImage(objectUrl);
    const maxSize = 1600;
    const scale = Math.min(1, maxSize / Math.max(image.naturalWidth, image.naturalHeight));
    const width = Math.max(1, Math.round(image.naturalWidth * scale));
    const height = Math.max(1, Math.round(image.naturalHeight * scale));
    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const context = canvas.getContext('2d');
    context.drawImage(image, 0, 0, width, height);
    return canvas.toDataURL('image/jpeg', 0.86);
  } finally {
    URL.revokeObjectURL(objectUrl);
  }
}

function loadImage(src) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => resolve(image);
    image.onerror = () => reject(new Error('Imej tidak dapat dibaca.'));
    image.src = src;
  });
}

async function readExifGps(file) {
  try {
    const buffer = await file.arrayBuffer();
    const view = new DataView(buffer);
    if (view.getUint16(0) !== 0xffd8) {
      return null;
    }

    let offset = 2;
    while (offset < view.byteLength) {
      if (view.getUint8(offset) !== 0xff) {
        break;
      }
      const marker = view.getUint8(offset + 1);
      const length = view.getUint16(offset + 2, false);
      if (marker === 0xe1 && readAscii(view, offset + 4, 6) === 'Exif\0\0') {
        return parseTiff(view, offset + 10);
      }
      offset += 2 + length;
    }
  } catch (_) {
    return null;
  }
  return null;
}

function parseTiff(view, tiffStart) {
  const endian = readAscii(view, tiffStart, 2);
  const little = endian === 'II';
  if (!little && endian !== 'MM') {
    return null;
  }

  const firstIfdOffset = readUint32(view, tiffStart + 4, little);
  const ifd0 = readIfd(view, tiffStart, firstIfdOffset, little);
  const gpsOffset = readFirstValue(view, tiffStart, ifd0[0x8825], little);
  const dateText = readFirstValue(view, tiffStart, ifd0[0x0132], little);

  if (!gpsOffset) {
    return {
      capturedAt: exifDateToIso(dateText)
    };
  }

  const gpsIfd = readIfd(view, tiffStart, gpsOffset, little);
  const latRef = readFirstValue(view, tiffStart, gpsIfd[0x0001], little);
  const latValues = readEntryValue(view, tiffStart, gpsIfd[0x0002], little);
  const lonRef = readFirstValue(view, tiffStart, gpsIfd[0x0003], little);
  const lonValues = readEntryValue(view, tiffStart, gpsIfd[0x0004], little);
  const altRef = readFirstValue(view, tiffStart, gpsIfd[0x0005], little);
  const altValue = readFirstValue(view, tiffStart, gpsIfd[0x0006], little);

  const latitude = dmsToDecimal(latValues, latRef);
  const longitude = dmsToDecimal(lonValues, lonRef);
  let altitude = typeof altValue === 'number' ? altValue : null;
  if (altitude != null && Number(altRef) === 1) {
    altitude *= -1;
  }

  return {
    latitude,
    longitude,
    altitude,
    capturedAt: exifDateToIso(dateText)
  };
}

function readIfd(view, tiffStart, ifdOffset, little) {
  const entries = {};
  if (!ifdOffset) {
    return entries;
  }
  const absolute = tiffStart + ifdOffset;
  if (absolute + 2 > view.byteLength) {
    return entries;
  }
  const count = readUint16(view, absolute, little);
  for (let index = 0; index < count; index += 1) {
    const entryOffset = absolute + 2 + index * 12;
    if (entryOffset + 12 > view.byteLength) {
      break;
    }
    const tag = readUint16(view, entryOffset, little);
    entries[tag] = {
      tag,
      type: readUint16(view, entryOffset + 2, little),
      count: readUint32(view, entryOffset + 4, little),
      valueOffset: readUint32(view, entryOffset + 8, little),
      entryOffset
    };
  }
  return entries;
}

function readEntryValue(view, tiffStart, entry, little) {
  if (!entry) {
    return null;
  }
  const size = typeSize(entry.type) * entry.count;
  const valueOffset = size <= 4 ? entry.entryOffset + 8 : tiffStart + entry.valueOffset;
  const values = [];

  for (let index = 0; index < entry.count; index += 1) {
    const offset = valueOffset + index * typeSize(entry.type);
    if (offset >= view.byteLength) {
      break;
    }
    if (entry.type === 1) {
      values.push(view.getUint8(offset));
    } else if (entry.type === 2) {
      return readAscii(view, valueOffset, entry.count).replace(/\0/g, '').trim();
    } else if (entry.type === 3) {
      values.push(readUint16(view, offset, little));
    } else if (entry.type === 4) {
      values.push(readUint32(view, offset, little));
    } else if (entry.type === 5) {
      const numerator = readUint32(view, offset, little);
      const denominator = readUint32(view, offset + 4, little);
      values.push(denominator ? numerator / denominator : null);
    }
  }

  return values.length === 1 ? values[0] : values;
}

function readFirstValue(view, tiffStart, entry, little) {
  const value = readEntryValue(view, tiffStart, entry, little);
  return Array.isArray(value) ? value[0] : value;
}

function dmsToDecimal(values, ref) {
  if (!Array.isArray(values) || values.length < 3) {
    return null;
  }
  const decimal = values[0] + values[1] / 60 + values[2] / 3600;
  if (ref === 'S' || ref === 'W') {
    return decimal * -1;
  }
  return decimal;
}

function typeSize(type) {
  return {
    1: 1,
    2: 1,
    3: 2,
    4: 4,
    5: 8
  }[type] || 1;
}

function readAscii(view, offset, length) {
  let text = '';
  for (let index = 0; index < length && offset + index < view.byteLength; index += 1) {
    text += String.fromCharCode(view.getUint8(offset + index));
  }
  return text;
}

function readUint16(view, offset, little) {
  return view.getUint16(offset, little);
}

function readUint32(view, offset, little) {
  return view.getUint32(offset, little);
}

function exifDateToIso(value) {
  if (!value || typeof value !== 'string') {
    return null;
  }
  const match = value.match(/^(\d{4}):(\d{2}):(\d{2})\s+(\d{2}):(\d{2}):(\d{2})/);
  if (!match) {
    return null;
  }
  const [, year, month, day, hour, minute, second] = match;
  return new Date(`${year}-${month}-${day}T${hour}:${minute}:${second}`).toISOString();
}

function getBounds(photos) {
  const lats = photos.map((photo) => photo.latitude);
  const lons = photos.map((photo) => photo.longitude);
  let minLat = Math.min(...lats);
  let maxLat = Math.max(...lats);
  let minLon = Math.min(...lons);
  let maxLon = Math.max(...lons);

  if (minLat === maxLat) {
    minLat -= 0.0005;
    maxLat += 0.0005;
  }
  if (minLon === maxLon) {
    minLon -= 0.0005;
    maxLon += 0.0005;
  }

  return { minLat, maxLat, minLon, maxLon };
}

function projectLatitude(latitude, bounds) {
  return 92 - ((latitude - bounds.minLat) / (bounds.maxLat - bounds.minLat)) * 84;
}

function projectLongitude(longitude, bounds) {
  return 8 + ((longitude - bounds.minLon) / (bounds.maxLon - bounds.minLon)) * 84;
}

function googleSearchUrl(photo) {
  return `https://www.google.com/maps/search/?api=1&query=${photo.latitude},${photo.longitude}`;
}

function googleEmbedUrl(photo) {
  return `https://www.google.com/maps?q=${photo.latitude},${photo.longitude}&z=18&output=embed`;
}

function googleDirectionsUrl(photos) {
  const located = photos.filter(hasCoordinate);
  if (!located.length) {
    return 'https://www.google.com/maps';
  }
  const origin = `${located[0].latitude},${located[0].longitude}`;
  const destinationPhoto = located[located.length - 1];
  const destination = `${destinationPhoto.latitude},${destinationPhoto.longitude}`;
  const params = new URLSearchParams({
    api: '1',
    origin,
    destination
  });
  const waypoints = located.slice(1, -1).map((photo) => `${photo.latitude},${photo.longitude}`);
  if (waypoints.length) {
    params.set('waypoints', waypoints.join('|'));
  }
  return `https://www.google.com/maps/dir/?${params.toString()}`;
}

function statCard(label, value) {
  return `<div class="stat-card"><strong>${escapeHtml(String(value))}</strong><span>${escapeHtml(label)}</span></div>`;
}

function numericProjectFields() {
  return [
    'levelOffset',
    'visitLatitude',
    'visitLongitude',
    'visitAltitude',
    'visitAccuracy'
  ];
}

function normalizeCategory(category) {
  if (!category) {
    return 'Kerja tanah';
  }
  const legacyMap = {
    Longkang: 'Sistem saliran',
    Struktur: 'Kerja tanah',
    Cerun: 'Kerja tanah',
    Utiliti: 'Retikulasi air',
    Keselamatan: 'Umum'
  };
  const mapped = legacyMap[category] || category;
  return photoCategories.includes(mapped) ? mapped : 'Umum';
}

function normalizeAnnotations(annotations) {
  if (!Array.isArray(annotations)) {
    return [];
  }

  return annotations.map((annotation) => {
    const type = annotation.type === 'circle' ? 'circle' : 'arrow';
    const migrated = migrateLegacyAnnotation(annotation, type);
    return {
      id: annotation.id || createId('mark'),
      type,
      color: sanitizeColor(annotation.color),
      text: String(annotation.text || ''),
      startX: clamp(numberOrNull(migrated.startX) ?? 42, 0, 100),
      startY: clamp(numberOrNull(migrated.startY) ?? 50, 0, 100),
      endX: clamp(numberOrNull(migrated.endX) ?? 58, 0, 100),
      endY: clamp(numberOrNull(migrated.endY) ?? 50, 0, 100)
    };
  });
}

function migrateLegacyAnnotation(annotation, type) {
  if (isFiniteNumber(annotation.startX) &&
      isFiniteNumber(annotation.startY) &&
      isFiniteNumber(annotation.endX) &&
      isFiniteNumber(annotation.endY)) {
    return annotation;
  }

  const x = numberOrNull(annotation.x) ?? 50;
  const y = numberOrNull(annotation.y) ?? 50;
  if (type === 'circle') {
    return {
      startX: x - 10,
      startY: y - 10,
      endX: x + 10,
      endY: y + 10
    };
  }

  const vector = legacyDirectionVector(annotation.direction);
  return {
    startX: x - vector.x * 10,
    startY: y - vector.y * 10,
    endX: x + vector.x * 10,
    endY: y + vector.y * 10
  };
}

function legacyDirectionVector(direction) {
  const vectors = {
    E: { x: 1, y: 0 },
    NE: { x: 0.707, y: -0.707 },
    N: { x: 0, y: -1 },
    NW: { x: -0.707, y: -0.707 },
    W: { x: -1, y: 0 },
    SW: { x: -0.707, y: 0.707 },
    S: { x: 0, y: 1 },
    SE: { x: 0.707, y: 0.707 }
  };
  return vectors[direction] || vectors.E;
}

function sanitizeColor(color) {
  return /^#[0-9a-fA-F]{6}$/.test(color || '') ? color : '#e11d48';
}

function hexToRgba(hex, alpha) {
  const clean = sanitizeColor(hex).slice(1);
  const red = parseInt(clean.slice(0, 2), 16);
  const green = parseInt(clean.slice(2, 4), 16);
  const blue = parseInt(clean.slice(4, 6), 16);
  return `rgba(${red}, ${green}, ${blue}, ${alpha})`;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function formatCoordinate(photo) {
  if (!hasCoordinate(photo)) {
    return 'Koordinat tidak tersedia';
  }
  return `${formatNumber(photo.latitude, 6)}, ${formatNumber(photo.longitude, 6)}`;
}

function formatAltitude(photo) {
  return isFiniteNumber(photo.altitude) ? `${formatNumber(photo.altitude, 3)} m` : 'Altitude tidak tersedia';
}

function formatLevel(photo) {
  return isFiniteNumber(photo.adjustedLevel) ? `${formatNumber(photo.adjustedLevel, 3)} m` : 'Level tidak tersedia';
}

function formatAccuracy(value) {
  return isFiniteNumber(value) ? `${formatNumber(value, 2)} m` : '-';
}

function formatNumber(value, digits) {
  const number = numberOrNull(value);
  return number == null ? '-' : number.toFixed(digits);
}

function valueForInput(value) {
  return value == null ? '' : value;
}

function numberOrNull(value) {
  if (value === null || value === undefined || value === '') {
    return null;
  }
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
}

function isFiniteNumber(value) {
  return value !== null && value !== undefined && value !== '' && Number.isFinite(Number(value));
}

function joinSentences(current, next) {
  return current?.trim() ? `${current.trim()} ${next}` : next;
}

function createId(prefix) {
  return `${prefix}-${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

function dateStamp() {
  return new Date().toISOString().slice(0, 10);
}

function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function escapeSvg(value) {
  return escapeHtml(value).replace(/\n/g, ' ');
}

function setBusy(isBusy, message = 'Offline ready') {
  el.cameraButton.disabled = isBusy;
  el.galleryButton.disabled = isBusy;
  el.demoButton.disabled = isBusy;
  el.visitGpsButton.disabled = isBusy;
  el.storageStatus.textContent = isBusy ? message : (navigator.onLine ? 'Offline ready' : 'Offline mode');
}

function updateOnlineStatus() {
  el.storageStatus.textContent = navigator.onLine ? 'Offline ready' : 'Offline mode';
}

function toast(message) {
  const node = document.createElement('div');
  node.className = 'toast';
  node.textContent = message;
  document.body.appendChild(node);
  setTimeout(() => node.remove(), 4200);
}

function exportJson() {
  downloadText(
    `data-lawatan-tapak-${dateStamp()}.json`,
    JSON.stringify(state, null, 2),
    'application/json'
  );
}

function downloadText(fileName, text, mimeType) {
  const blob = new Blob([text], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = fileName;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function buildReportHtmlDocument() {
  return `<!doctype html>
<html lang="ms">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Laporan Lawatan Tapak</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.45; color: #17211f; margin: 24px; }
    h1, h2, h3 { color: #0f3f3a; }
    .report-cover { border-bottom: 3px solid #0f766e; padding-bottom: 18px; margin-bottom: 18px; }
    table { width: 100%; border-collapse: collapse; margin: 14px 0 22px; }
    th, td { border: 1px solid #cfdad7; padding: 8px; vertical-align: top; text-align: left; }
    th { background: #e7f3f1; }
    .report-photo { break-inside: avoid; border: 1px solid #cfdad7; border-radius: 8px; padding: 12px; margin-bottom: 14px; }
    img { width: 100%; max-height: 420px; object-fit: cover; border-radius: 6px; }
    .report-image-wrap { position: relative; border-radius: 6px; overflow: hidden; background: #eef3f2; min-height: 170px; margin-bottom: 10px; }
    .report-image-wrap img { display: block; margin-bottom: 0; }
    .annotation-svg { position: absolute; inset: 0; width: 100%; height: 100%; pointer-events: none; }
  </style>
</head>
<body>${el.printArea.innerHTML}</body>
</html>`;
}

function saveDebounced() {
  clearTimeout(saveTimer);
  saveTimer = setTimeout(async () => {
    await saveState(state);
    el.storageStatus.textContent = 'Disimpan';
    setTimeout(updateOnlineStatus, 1200);
  }, 350);
}

function openDb() {
  if (!dbPromise) {
    dbPromise = new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);
      request.onupgradeneeded = () => {
        request.result.createObjectStore(STORE_NAME);
      };
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }
  return dbPromise;
}

async function loadState() {
  try {
    const db = await openDb();
    const transaction = db.transaction(STORE_NAME, 'readonly');
    const store = transaction.objectStore(STORE_NAME);
    const stored = await requestToPromise(store.get(STATE_KEY));
    return stored || createDefaultState();
  } catch (_) {
    return createDefaultState();
  }
}

async function saveState(nextState) {
  const db = await openDb();
  const transaction = db.transaction(STORE_NAME, 'readwrite');
  transaction.objectStore(STORE_NAME).put(nextState, STATE_KEY);
  await transactionToPromise(transaction);
}

function requestToPromise(request) {
  return new Promise((resolve, reject) => {
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

function transactionToPromise(transaction) {
  return new Promise((resolve, reject) => {
    transaction.oncomplete = () => resolve();
    transaction.onerror = () => reject(transaction.error);
    transaction.onabort = () => reject(transaction.error);
  });
}

function registerServiceWorker() {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('./sw.js').catch(() => {});
  }
}

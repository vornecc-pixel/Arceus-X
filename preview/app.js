(() => {
  const $ = (selector, root = document) => root.querySelector(selector);
  const tabs = ['ESP / World', 'Combat', 'Misc', 'Settings'];
  const mixes = {
    'NH Classic': { accent:'#98bcff', bg:'#101114', panel:'#141519', item:'#1c1d23', line:'#24262d', border:'#343740', text:'#b4b4b4', mute:'#646464', font:"'Courier New',monospace", watermark:true, keys:true },
    'Arceus Purple': { accent:'#a43cff', bg:'#0d0d0f', panel:'#141416', item:'#1a1a1d', line:'#2b2b31', border:'#34343a', text:'#c9c9d0', mute:'#72727d', font:'Arial,sans-serif', watermark:true, keys:true },
    'Blood Eye': { accent:'#ff3232', bg:'#0e0a0b', panel:'#140e0f', item:'#1c1416', line:'#302225', border:'#463034', text:'#c8bebe', mute:'#766264', font:'Arial,sans-serif', watermark:true, keys:false },
    'Frost Glass': { accent:'#8cd2ff', bg:'#0c1016', panel:'#11161e', item:'#181f2a', line:'#283446', border:'#3a4a62', text:'#cddceb', mute:'#70829b', font:"'Courier New',monospace", watermark:false, keys:true },
    'Terminal': { accent:'#4cd37b', bg:'#080b09', panel:'#0c110e', item:'#121914', line:'#1e3426', border:'#284834', text:'#96e1af', mute:'#467858', font:"'Courier New',monospace", watermark:true, keys:true },
    'Sakura': {accent:'#ff92b8',bg:'#140c12',panel:'#1c1119',item:'#271721',line:'#422735',border:'#5a3648',text:'#f4dbe6',mute:'#a5748c',font:'Arial,sans-serif',watermark:true,keys:true},
    'Aurora': {accent:'#5be8be',bg:'#081112',panel:'#0b1719',item:'#0f2022',line:'#213b3e',border:'#2d4e52',text:'#cdeee7',mute:'#649792',font:"'Courier New',monospace",watermark:true,keys:true},
    'Obsidian': {accent:'#9da6ff',bg:'#07080b',panel:'#0d0e13',item:'#15161d',line:'#252732',border:'#383a48',text:'#dcdee8',mute:'#757889',font:'Arial,sans-serif',watermark:true,keys:true},
    'Copper': {accent:'#e8925d',bg:'#120c0a',panel:'#1b120f',item:'#261914',line:'#412c22',border:'#533829',text:'#ecdac9',mute:'#9f7f69',font:'Arial,sans-serif',watermark:true,keys:true},
    'Solarized': {accent:'#b58900',bg:'#001e26',panel:'#002b36',item:'#073642',line:'#1e4b56',border:'#305f68',text:'#dce1c9',mute:'#839496',font:"'Courier New',monospace",watermark:true,keys:true},
    'Violet Ice': {accent:'#b4a6ff',bg:'#0d0d16',panel:'#13131f',item:'#1b1c2c',line:'#2d3045',border:'#3e425b',text:'#dee0f4',mute:'#8086a5',font:"'Courier New',monospace",watermark:true,keys:true}
  };
  const T = (label, flag, on = false, colors = []) => ({type:'toggle',label,flag,on,colors});
  const S = (label, flag, options, value) => ({type:'select',label,flag,options,value});
  const R = (label, flag, min, max, value, suffix = '') => ({type:'range',label,flag,min,max,value,suffix});
  const B = (label, action) => ({type:'button',label,action});
  const K = (label, flag, key) => ({type:'keybind',label,flag,key});
  const L = label => ({type:'label',label});
  const group = (title, rows) => ({title,rows});
  const human = prefix => {
    const p = prefix === 'plr', name = p ? 'Players' : 'NPCs';
    const list = [T(`Master Enable (${name})`,`${prefix}_master`,true), T(`${name} ESP Toggle`,`${prefix}_enabled`)];
    if (p) list.push(R('ESP Update Rate (Hz)','player_esp_hz',30,240,60,' Hz'));
    list.push(S('Box Style',`${prefix}_style`,['Corners','Full'],'Corners'), R('Max Distance',`${prefix}_max_dist`,10,2000,500,'m'),
      T('Box',`${prefix}_box`,true,['#ffffff']), T('Name',`${prefix}_name`,true,['#ffffff']));
    if (p) list.push(T('Health Bar','plr_health',true,['#00ff00','#ff0000']));
    list.push(T('Distance',`${prefix}_dist`,true,['#ffffff']), T('Weapon',`${prefix}_weapon`,true,[p?'#00ffff':'#ffb43c']));
    if (p) list.push(T('Skeleton','plr_skel',true,['#ffffff']));
    list.push(T('Chams',`${prefix}_chams`,true,[p?'#00ffff':'#3cff78','#ff3250']));
    return list;
  };
  const layout = {
    'ESP / World': [
      [group('Player ESP',human('plr')),group('Ore ESP (Icons)',[T('Master Enable (Ores)','ore_master',true),T('Ore ESP Toggle','ore_enabled'),R('Max Distance','ore_max_dist',10,2000,300,'m'),T('Show Distance','ore_dist',true),...['Cactus','MetalNode','SulfurNode','Tree','Meteor','StoneNode'].map(x=>T(x,'ore_'+x,true))])],
      [group('NPC ESP',human('npc')),group('Heli ESP',[T('Master Enable (Heli)','heli_master',true),T('Heli ESP Toggle','heli_enabled'),S('Box Style','heli_style',['Corners','Full'],'Full'),R('Max Distance','heli_max_dist',10,5000,2000,'m'),T('Chams','heli_chams',true),T('Show Distance','heli_dist',true)]),group('ESP Preview',[{type:'preview'}])]
    ],
    'Combat': [
      [group('Aimbot',[T('Aimbot Enabled','aim_enabled'),S('Lock Mode','aim_lock_mode',['Always','Hold'],'Always'),K('Aimbot Keybind','aim_key','Q'),S('Bone','aim_bone',['Head','Hrp'],'Head'),R('FOV','aim_fov',10,500,220,' px'),R('Max Distance','aim_distance',0,2000,0,' studs'),R('Smoothing','aim_smoothing',1,20,2),R('Bullet Speed','aim_bullet_speed',50,3000,900)]),group('Aimbot Options',[T('FOV Circle','Aim_FOV_Circle'),T('Prediction','aim_prediction',true),T('Target NPCs','aim_target_npcs'),T('Wall Check','aim_wall_check'),T('Team Check','aim_team_check'),L('Always: the keybind toggles the aimbot. Hold: aim only while the key is held. FOV is a pixel radius; distance 0 = unlimited.')])]
    ],
    'Misc': [
      [group('Staff Detection',[T('Enable Staff Monitor','staff_monitor'),L('Not scanned yet.'),B('Scan Now','scan')]),group('System',[B('Unload Script & Clear Memory','unload')])],
      [group('Staff ESP',[T('Highlight Staff','staff_esp'),B('Refresh Highlights','demo'),B('Clear Highlights','demo')]),group('Mining (Silent Insta-Hit)',[T('Enable Insta-Hit Weakspot','weakspot_enabled'),L('Silently snaps the camera at the nearest weakspot for one tick, activates the tool, then restores the camera. No visible lock. Radius: 50 studs.')])]
    ],
    'Settings': [
      [group('Configs',[S('Select config','config',['None'],'None'),B('Save config','demo'),B('Load config','demo'),T('Auto Load Selected','__autoload')]),group('Appearance',[S('Theme','theme',Object.keys(mixes),'Arceus Purple'),S('Font','font',['Code','SourceSans','Gotham','RobotoMono'],'Code'),R('UI Scale','scale',.5,1.5,1),R('Window Opacity','opacity',0,1,1)])],
      [group('Other',[B('Replay Intro','intro'),B('Unload Menu','unload'),L('Settings are simulated in this presentation.')])]
    ]
  };

  let state = {}, colors = {}, activeTab = 'ESP / World', currentMix = 'Arceus Purple', introTimers = [], menuShown = true;
  const stage = $('#stage'), menuWrap = $('#menu-wrap'), stageArea = $('#stage-area'), deviceShell = $('#device-shell');
  const devices = {
    pc: {width:1280,height:720,touch:false,label:'PC · 1280 × 720',description:'Two-column desktop layout'},
    portrait: {width:390,height:844,touch:true,label:'MOBILE · PORTRAIT',description:'390 × 844 · Single-column touch layout'},
    landscape: {width:844,height:390,touch:true,label:'MOBILE · LANDSCAPE',description:'844 × 390 · Two-column touch layout'}
  };
  let selectedDevice = 'pc';
  function defaults(){ state={}; colors={}; Object.values(layout).flat(2).forEach(g=>g.rows.forEach(r=>{if(r.flag !== undefined) state[r.flag] = r.type==='toggle'?r.on:r.value; if(r.colors) colors[r.flag]=[...r.colors]})); currentMix='Arceus Purple'; activeTab='ESP / World'; menuShown=true; }
  function esc(s){return String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
  function row(r){
    if(r.type==='toggle') return `<div class="row"><button class="toggle ${state[r.flag]?'on':''}" data-toggle="${esc(r.flag)}" aria-pressed="${!!state[r.flag]}" aria-label="${esc(r.label)}"></button><span class="row-label" data-toggle="${esc(r.flag)}">${esc(r.label)}</span>${(colors[r.flag]||[]).map((c,i)=>`<label class="swatch" style="background:${esc(c)}" title="Change ${esc(r.label)} color"><input type="color" data-color="${esc(r.flag)}" data-index="${i}" value="${esc(c)}" aria-label="${esc(r.label)} color ${i+1}"></label>`).join('')}</div>`;
    if(r.type==='select') return `<div class="select-row"><div class="control-heading">${esc(r.label)}</div><select data-select="${esc(r.flag)}" aria-label="${esc(r.label)}">${r.options.map(o=>`<option ${o===state[r.flag]?'selected':''}>${esc(o)}</option>`).join('')}</select></div>`;
    if(r.type==='range'){const pct=(state[r.flag]-r.min)/(r.max-r.min)*100;return `<div class="slider-row"><div class="control-heading"><span>${esc(r.label)}</span><span data-value="${esc(r.flag)}">${state[r.flag]}${esc(r.suffix||'')}</span></div><div class="slider-controls"><button class="slider-step" data-step="-1" aria-label="Decrease ${esc(r.label)}">−</button><input type="range" data-range="${esc(r.flag)}" data-suffix="${esc(r.suffix||'')}" min="${r.min}" max="${r.max}" step="${r.max<=1?'.001':'1'}" value="${state[r.flag]}" style="--pct:${pct}%" aria-label="${esc(r.label)}"><button class="slider-step" data-step="1" aria-label="Increase ${esc(r.label)}">+</button></div></div>`;}
    if(r.type==='keybind') return `<div class="select-row"><div class="control-heading"><span>${esc(r.label)}</span></div><button class="ui-button" data-action="keybind" aria-label="${esc(r.label)}">[${esc(r.key)}]</button></div>`;
    if(r.type==='button') return `<button class="ui-button" data-action="${esc(r.action)}">${esc(r.label)}</button>`;
    if(r.type==='label') return `<p class="label-text">${esc(r.label)}</p>`;
    if(r.type==='preview') return `<div class="preview-stage"><div class="figure"><div class="part head"></div><div class="part torso"></div><div class="part arm1"></div><div class="part arm2"></div><div class="part leg1"></div><div class="part leg2"></div><svg class="skeleton" viewBox="0 0 60 130" fill="none" stroke="white" stroke-width="1.5"><path d="M30 10V68 M16 28H44 M16 28L9 64 M44 28L51 64 M30 68L22 98V124 M30 68L38 98V124"/></svg><div class="esp-frame"></div><div class="health"><i></i></div><div class="figure-label name">Target</div><div class="figure-label distance">42m</div><div class="figure-label weapon">Sword</div></div></div>`;
    return '';
  }
  function render(){
    $('#tabs').innerHTML=tabs.map(t=>`<button class="tab ${activeTab===t?'selected':''}" data-tab="${esc(t)}">${esc(t)}</button>`).join('');
    $('#menu-body').innerHTML=`<div class="columns">${layout[activeTab].map(col=>`<div class="column">${col.map(g=>`<section class="group"><div class="group-title">${esc(g.title)}</div>${g.rows.map(row).join('')}</section>`).join('')}</div>`).join('')}</div>`;
    updateFigure();
  }
  function updateFigure(){
    const fig=$('.figure'); if(!fig)return;
    fig.classList.toggle('chams',!!state.plr_chams);
    $('.esp-frame',fig).style.display=state.plr_box?'':'none'; $('.esp-frame',fig).classList.toggle('corners',state.plr_style==='Corners');
    $('.name',fig).style.display=state.plr_name?'':'none'; $('.distance',fig).style.display=state.plr_dist?'':'none'; $('.weapon',fig).style.display=state.plr_weapon?'':'none'; $('.health',fig).style.display=state.plr_health?'':'none'; $('.skeleton',fig).style.display=state.plr_skel?'':'none';
    const partColor=colors.plr_chams?.[0]; if(partColor) fig.style.setProperty('--chams',partColor);
    fig.querySelectorAll('.part').forEach(part=>{part.style.background=state.plr_chams ? partColor+'a6':''; part.style.outlineColor=state.plr_chams?colors.plr_chams[1]:''});
    if(colors.plr_box) { $('.esp-frame',fig).style.borderColor=colors.plr_box[0]; $('.esp-frame',fig).style.color=colors.plr_box[0]; }
    if(colors.plr_name) $('.name',fig).style.color=colors.plr_name[0];
    if(colors.plr_dist) $('.distance',fig).style.color=colors.plr_dist[0];
    if(colors.plr_weapon) $('.weapon',fig).style.color=colors.plr_weapon[0];
    if(colors.plr_skel) $('.skeleton',fig).style.stroke=colors.plr_skel[0];
  }
  function applyMix(name){
    const m=mixes[name]||mixes['NH Classic']; currentMix=name;
    const vars={accent:m.accent,'ui-bg':m.bg,'ui-panel':m.panel,'ui-item':m.item,'ui-line':m.line,'ui-border':m.border,'ui-text':m.text,'ui-mute':m.mute,'ui-font':m.font};
    Object.entries(vars).forEach(([key,value])=>document.documentElement.style.setProperty('--'+key,value));
    state.NH_Mix=name; state.theme=name;state.NH_Watermark=m.watermark;state.NH_KeybindList=m.keys;
    $('#watermark').style.display=m.watermark?'':'none';$('#keybinds').style.display=m.keys?'':'none';$('#current-theme').textContent=name.toUpperCase();
  }
  function showMenu(show){menuShown=show; menuWrap.style.display=show?'':'none'; $('#floating').style.display=(devices[selectedDevice].touch||!show)?'block':'none';}
  function fit(){
    const device=devices[selectedDevice], w=device.width, h=device.height;
    const border=device.touch?6:0;
    const areaWidth=stageArea.clientWidth || w;
    const maxScreenWidth=selectedDevice==='portrait'?300:w;
    const screenWidth=Math.max(1,Math.min(maxScreenWidth,areaWidth-(device.touch?40:0)-border*2));
    const screenScale=screenWidth/w;
    deviceShell.style.width=(screenWidth+border*2)+'px';
    deviceShell.style.height=(h*screenScale+border*2)+'px';
    stage.style.width=w+'px';stage.style.height=h+'px';stage.style.transform=`scale(${screenScale})`;
    const availableX=w-16,availableY=h-16;
    const menuScale=Math.min(1,availableX/280,availableY/180);
    const width=Math.min(750,availableX/menuScale);
    const desiredHeight=device.touch&&h>w?Math.max(600,availableY/menuScale):600;
    const height=Math.min(desiredHeight,availableY/menuScale);
    menuWrap.style.width=width+'px';menuWrap.style.height=height+'px';
    menuWrap.style.setProperty('--scale',menuScale);
    menuWrap.classList.toggle('compact',width<560);
    menuWrap.classList.toggle('touch',device.touch);
  }
  function selectDevice(id){
    selectedDevice=id; const device=devices[id];
    stopIntro();stageArea.classList.toggle('mobile',device.touch);
    document.querySelectorAll('.device-choice').forEach(button=>{
      const active=button.dataset.device===id;
      button.classList.toggle('active',active);button.setAttribute('aria-pressed',String(active));
    });
    $('#device-label').textContent=device.label;$('#device-description').textContent=device.description;
    $('#device-hint').innerHTML=device.touch?'TAP CIRCLE TO TOGGLE <span class="bottom-separator">·</span> DRAG TO MOVE':'<kbd>RIGHT SHIFT</kbd> TOGGLE MENU <span class="bottom-separator">·</span> <span class="desktop-label">DRAG WINDOW TO MOVE</span>';
    menuWrap.style.left='50%';menuWrap.style.top='50%';const fab=$('#floating');fab.style.left='';fab.style.top='';fab.style.right='';fab.style.bottom='';showMenu(true);fit();
  }
  function stopIntro(){introTimers.forEach(clearTimeout);introTimers=[];$('#intro').hidden=true;$('#intro').classList.remove('smash');$('#intro-checks').hidden=false;$('#intro-reveal').hidden=true;}
  function later(fn,ms){introTimers.push(setTimeout(fn,ms));}
  function playIntro(){
    stopIntro();showMenu(true); const overlay=$('#intro'); overlay.hidden=false;
    const device=devices[selectedDevice],orientation=device.width>=device.height?'Landscape':'Portrait';
    const checks=[['Device',device.touch?'Mobile':'Desktop'],['Layout',orientation+(menuWrap.classList.contains('compact')?' / 1 col':' / 2 col')],['Screen size',device.width+'x'+device.height],['Client version','Simulated'],['Game loaded','Simulated'],['Local player','Simulated'],['PlayerGui','Simulated'],['Frame rate','60 FPS'],['Network ping','42 ms'],['Input',device.touch?'Touch':'Keyboard / mouse']];
    $('#check-list').innerHTML='';$('#terminal').textContent='';$('#intro-progress').style.width='0%';$('#intro-status').textContent='Starting up...';
    const terminal=['ARC3USX.EXE boot v1.0.0','init compat scanner ...','resolve sym_4c1 = 0xa5b702','chunk[142] crc 0xe14b09 ok','stack.check 0xf3a728 ok'];
    checks.forEach(([key,val],i)=>later(()=>{ $('#check-list').insertAdjacentHTML('beforeend',`<div class="check-line"><span>${esc(key)}</span><span>${esc(val)} &nbsp; OK</span></div>`); $('#intro-progress').style.width=((i+1)/checks.length*100)+'%';$('#intro-status').textContent='Checking '+key.toLowerCase()+'...';terminal.push('$ check '+key.toLowerCase()+' ...','  [OK] '+val,'alloc 1a8e bytes @ 0x54ac2f');$('#terminal').textContent=terminal.join('\n');},250+i*240));
    later(()=>{$('#intro-status').textContent='Compatible: all checks passed';},2450);
    later(()=>{$('#intro-checks').hidden=true;$('#intro-reveal').hidden=false;$('#terminal').style.opacity='.12';},2900);
    later(()=>overlay.classList.add('smash'),4900);
    later(()=>{stopIntro();$('#terminal').style.opacity='';},5750);
  }
  $('#tabs').addEventListener('click',e=>{const tab=e.target.closest('[data-tab]');if(tab){activeTab=tab.dataset.tab;render();$('#menu-body').scrollTop=0;}});
  $('#menu-body').addEventListener('click',e=>{
    const toggle=e.target.closest('[data-toggle]');if(toggle){const key=toggle.dataset.toggle;state[key]=!state[key];if(key==='NH_Watermark')$('#watermark').style.display=state[key]?'':'none';if(key==='NH_KeybindList')$('#keybinds').style.display=state[key]?'':'none';const button=$(`.toggle[data-toggle="${key}"]`);button.classList.toggle('on',state[key]);button.setAttribute('aria-pressed',state[key]);updateFigure();return;}
    const step=e.target.closest('[data-step]'); if(step){const input=step.parentElement.querySelector('input'); if(step.dataset.step==='1')input.stepUp();else input.stepDown();input.dispatchEvent(new Event('input',{bubbles:true}));return;}
    const action=e.target.closest('[data-action]')?.dataset.action;if(!action)return;
    if(action==='next-mix'){const keys=Object.keys(mixes);applyMix(keys[(keys.indexOf(currentMix)+1)%keys.length]);render();}
    if(action==='intro')playIntro();if(action==='unload')showMenu(false);if(action==='scan'){e.target.textContent='No staff detected';setTimeout(()=>{if(e.target)e.target.textContent='Scan Now';},2000)}
  });
  $('#menu-body').addEventListener('input',e=>{const el=e.target;if(el.dataset.range){state[el.dataset.range]=Number(el.value);const pct=(el.value-el.min)/(el.max-el.min)*100;el.style.setProperty('--pct',pct+'%');$(`[data-value="${el.dataset.range}"]`).textContent=el.value+(el.dataset.suffix||'');}if(el.dataset.color){colors[el.dataset.color][Number(el.dataset.index)]=el.value;el.parentElement.style.background=el.value;updateFigure();}});
  $('#menu-body').addEventListener('change',e=>{const key=e.target.dataset.select;if(!key)return;state[key]=e.target.value;if(key==='NH_Mix'||key==='theme'){applyMix(e.target.value);render();}else updateFigure();});
  document.querySelectorAll('.device-choice').forEach(button=>button.addEventListener('click',()=>selectDevice(button.dataset.device)));
  $('#replay').addEventListener('click',playIntro);$('#skip-intro').addEventListener('click',stopIntro);$('#close-menu').addEventListener('click',()=>showMenu(false));$('#floating').addEventListener('click',()=>{if(fabMoved){fabMoved=false;return;} showMenu(!menuShown);});
  $('#reset').addEventListener('click',()=>{stopIntro();defaults();applyMix(currentMix);render();showMenu(true);menuWrap.style.left='50%';menuWrap.style.top='50%';});
  document.addEventListener('keydown',e=>{if(e.code==='ShiftRight'&&!e.repeat&&!['INPUT','SELECT'].includes(document.activeElement.tagName)){e.preventDefault();showMenu(!menuShown);}});
  let drag=null;$('#drag-handle').addEventListener('pointerdown',e=>{if(e.target.closest('button'))return;const rect=menuWrap.getBoundingClientRect(),parent=stage.getBoundingClientRect();drag={dx:e.clientX-(rect.left+rect.width/2),dy:e.clientY-(rect.top+rect.height/2),left:parent.left,top:parent.top,scale:parent.width/devices[selectedDevice].width};e.currentTarget.setPointerCapture(e.pointerId)});$('#drag-handle').addEventListener('pointermove',e=>{if(!drag||!drag.scale)return;menuWrap.style.left=(e.clientX-drag.left-drag.dx)/drag.scale+'px';menuWrap.style.top=(e.clientY-drag.top-drag.dy)/drag.scale+'px'});$('#drag-handle').addEventListener('pointerup',()=>drag=null);$('#drag-handle').addEventListener('pointercancel',()=>drag=null);
  let fabDrag=null, fabMoved=false;
  const fab=$('#floating');
  fab.addEventListener('pointerdown',e=>{if(!devices[selectedDevice].touch)return;const rect=fab.getBoundingClientRect(),parent=stage.getBoundingClientRect();fabMoved=false;fabDrag={x:e.clientX,y:e.clientY,left:rect.left,top:rect.top,scale:parent.width/devices[selectedDevice].width};fab.setPointerCapture(e.pointerId)});
  fab.addEventListener('pointermove',e=>{if(!fabDrag)return;const dx=e.clientX-fabDrag.x,dy=e.clientY-fabDrag.y;if(dx*dx+dy*dy>36)fabMoved=true;if(!fabMoved)return;const parent=stage.getBoundingClientRect(),scale=fabDrag.scale;fab.style.left=Math.max(0,Math.min(devices[selectedDevice].width-52,(fabDrag.left-parent.left+dx)/scale))+'px';fab.style.top=Math.max(0,Math.min(devices[selectedDevice].height-52,(fabDrag.top-parent.top+dy)/scale))+'px';fab.style.right='auto';fab.style.bottom='auto';});
  fab.addEventListener('pointerup',()=>fabDrag=null);fab.addEventListener('pointercancel',()=>{fabDrag=null;fabMoved=false});
  window.addEventListener('resize',fit);
  const now=new Date();$('#menu-date').textContent=now.toLocaleDateString('en-US',{month:'short',day:'2-digit',year:'numeric'}).replace(',','');$('#hud-time').textContent=now.toLocaleTimeString([],{hour:'2-digit',minute:'2-digit',hour12:false});
  defaults();applyMix(currentMix);render();selectDevice('pc');
})();

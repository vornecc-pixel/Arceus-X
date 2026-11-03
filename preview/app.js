(() => {
  const $ = (selector, root = document) => root.querySelector(selector);
  const tabs = ['ESP / World', 'Combat', 'Misc', 'Mixes', 'Settings'];
  const mixes = {
    'NH Classic': { accent:'#98bcff', bg:'#101114', panel:'#141519', item:'#1c1d23', line:'#24262d', border:'#343740', text:'#b4b4b4', mute:'#646464', font:"'Courier New',monospace", watermark:true, keys:true },
    'Arceus Purple': { accent:'#a43cff', bg:'#0d0d0f', panel:'#141416', item:'#1a1a1d', line:'#2b2b31', border:'#34343a', text:'#c9c9d0', mute:'#72727d', font:'Arial,sans-serif', watermark:true, keys:true },
    'Blood Eye': { accent:'#ff3232', bg:'#0e0a0b', panel:'#140e0f', item:'#1c1416', line:'#302225', border:'#463034', text:'#c8bebe', mute:'#766264', font:'Arial,sans-serif', watermark:true, keys:false },
    'Frost Glass': { accent:'#8cd2ff', bg:'#0c1016', panel:'#11161e', item:'#181f2a', line:'#283446', border:'#3a4a62', text:'#cddceb', mute:'#70829b', font:"'Courier New',monospace", watermark:false, keys:true },
    'Terminal': { accent:'#4cd37b', bg:'#080b09', panel:'#0c110e', item:'#121914', line:'#1e3426', border:'#284834', text:'#96e1af', mute:'#467858', font:"'Courier New',monospace", watermark:true, keys:true }
  };
  const T = (label, flag, on = false, colors = []) => ({type:'toggle',label,flag,on,colors});
  const S = (label, flag, options, value) => ({type:'select',label,flag,options,value});
  const R = (label, flag, min, max, value, suffix = '') => ({type:'range',label,flag,min,max,value,suffix});
  const B = (label, action) => ({type:'button',label,action});
  const L = label => ({type:'label',label});
  const group = (title, rows) => ({title,rows});
  const human = prefix => {
    const p = prefix === 'plr', name = p ? 'Players' : 'NPCs';
    const list = [T(`Master Enable (${name})`,`${prefix}_master`,true),T(`${name} ESP Toggle`,`${prefix}_enabled`),R('Max Distance',`${prefix}_max_dist`,10,2000,500,'m'),S('Box Style',`${prefix}_style`,['Corners','Full'],'Corners'),T('Box',`${prefix}_box`,true,['#ffffff']),T('Name',`${prefix}_name`,true,['#ffffff']),T('Distance',`${prefix}_dist`,true,['#ffffff']),T('Weapon',`${prefix}_weapon`,true,[p?'#00ffff':'#ffb43c'])];
    if(p) list.push(T('Health Bar','plr_health',true,['#00ff00','#ff0000']),T('Skeleton','plr_skel',true,['#ffffff']));
    list.push(T('Chams',`${prefix}_chams`,true,[p?'#00ffff':'#3cff78','#ff3250'])); return list;
  };
  const slider = (label, flag, value=0) => R(label,flag,0,1,value);
  const layout = {
    'ESP / World': [
      [group('Player ESP',human('plr')),group('Ore ESP',[T('Master Enable (Ores)','ore_master',true),T('Ores ESP Toggle','ore_enabled'),R('Max Distance','ore_max_dist',10,2000,300,'m'),T('Show Distance','ore_dist',true),...['Cactus','MetalNode','SulfurNode','Tree','Meteor','StoneNode'].map(x=>T(x,'ore_'+x,true))])],
      [group('NPC ESP',human('npc')),group('Heli ESP',[T('Master Enable (Heli)','heli_master',true),T('Heli ESP Toggle','heli_enabled'),R('Max Distance','heli_max_dist',10,5000,2000,'m'),S('Box Style','heli_style',['Corners','Full'],'Full'),T('Chams','heli_chams',true),T('Show Distance','heli_dist',true)]),group('ESP Preview',[{type:'preview'}])]
    ],
    'Combat': [
      [group('Gun Master',[T('Enable Gun Mods','gunmods_enabled')]),group('Gun Timing',[T('Instant Equip','gunmods_inst_equip'),R('Equip Time','gunmods_equip_time',.001,1,.001),T('Instant ADS','gunmods_inst_ads'),R('ADS Time','gunmods_ads_time',.001,1,.001)]),group('Fire Rate & Spread',[T('No Spread + Custom Rate','gunmods_nospread'),R('Fire Rate','gunmods_rate',.01,1,.05),T('Force Auto','gunmods_force_auto',true),slider('Spread','gunmods_spread'),slider('ADS Spread','gunmods_ads_spread'),slider('Move Spread','gunmods_move_spread')]),group('Bow Mods',[T('Enable Bow Mods','bowmods_enabled'),T('Instant Draw (max charge)','bowmods_instdraw'),T('Instant Reload (crossbow)','bowmods_instreload'),T('No Shot Cooldown','bowmods_nocd'),T('No Recoil / No Tremble','bowmods_norecoil'),T('No Drop (every bow)','bowmods_nodrop')])],
      [group('Recoil & Bloom',[T('No Recoil','gunmods_norecoil'),slider('Visual Bloom','gunmods_bloom'),slider('Recoil Climb','gunmods_climb'),slider('Shake Max','gunmods_shakemax')]),group('Sway',[T('No Sway','gunmods_nosway'),slider('Sway','gunmods_sway'),slider('Sway Max','gunmods_swaymax'),slider('Bob Walk','gunmods_bobwalk'),slider('Bob Idle','gunmods_bobidle'),slider('Lean','gunmods_lean')]),group('Kick',[slider('Kick Pitch','gunmods_kickpitch'),slider('Kick Back','gunmods_kickback')]),group('Universal Bypass',[T('Infinite Ammo (every weapon)','universal_ammo'),T('No Air Block (fire while jumping)','universal_noair')])]
    ],
    'Misc': [
      [group('Staff Detection',[T('Enable Staff Monitor','staff_monitor'),T('Highlight Staff','staff_esp'),L('Staff scan inactive.'),B('Scan Now','scan')]),group('Auto Weakspot',[T('Enable Auto Weakspot','weakspot_enabled'),R('Max Distance','weakspot_max_dist',5,100,30,'m'),L('Creates an invisible marker at the nearest node; it does not redirect hits.')])],
      [group('System',[B('Unload Script & Clear Memory','unload')])]
    ],
    'Mixes': [
      [group('Mix',[S('Mix','NH_Mix',Object.keys(mixes),'NH Classic'),B('Next mix','next-mix')])],
      [group('HUD',[T('Watermark','NH_Watermark',true),T('Keybind list','NH_KeybindList',true)])]
    ],
    'Settings': [
      [group('Configs',[S('Select config','config',['None'],'None'),B('Save config','demo'),B('Load config','demo'),T('Auto Load Selected','__autoload')]),group('Appearance',[S('Theme','theme',Object.keys(mixes),'NH Classic'),S('Font','font',['Code','SourceSans','Gotham','RobotoMono'],'Code'),R('UI Scale','scale',.5,1.5,1),R('Window Opacity','opacity',0,1,1)])],
      [group('Other',[B('Replay Intro','intro'),B('Unload Menu','unload'),L('Settings are simulated in this presentation.')])]
    ]
  };
  let state = {}, colors = {}, activeTab = 'ESP / World', currentMix = 'NH Classic', introTimers = [], menuShown = true;
  const stage = $('#stage'), menuWrap = $('#menu-wrap');
  function defaults(){ state={}; colors={}; Object.values(layout).flat(2).forEach(g=>g.rows.forEach(r=>{if(r.flag !== undefined) state[r.flag] = r.type==='toggle'?r.on:r.value; if(r.colors) colors[r.flag]=[...r.colors]})); currentMix='NH Classic'; activeTab='ESP / World'; menuShown=true; }
  function esc(s){return String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
  function row(r){
    if(r.type==='toggle') return `<div class="row"><button class="toggle ${state[r.flag]?'on':''}" data-toggle="${esc(r.flag)}" aria-pressed="${!!state[r.flag]}" aria-label="${esc(r.label)}"></button><span class="row-label" data-toggle="${esc(r.flag)}">${esc(r.label)}</span>${(colors[r.flag]||[]).map((c,i)=>`<label class="swatch" style="background:${esc(c)}" title="Change ${esc(r.label)} color"><input type="color" data-color="${esc(r.flag)}" data-index="${i}" value="${esc(c)}" aria-label="${esc(r.label)} color ${i+1}"></label>`).join('')}</div>`;
    if(r.type==='select') return `<div class="select-row"><div class="control-heading">${esc(r.label)}</div><select data-select="${esc(r.flag)}" aria-label="${esc(r.label)}">${r.options.map(o=>`<option ${o===state[r.flag]?'selected':''}>${esc(o)}</option>`).join('')}</select></div>`;
    if(r.type==='range'){const pct=(state[r.flag]-r.min)/(r.max-r.min)*100;return `<div class="slider-row"><div class="control-heading"><span>${esc(r.label)}</span><span data-value="${esc(r.flag)}">${state[r.flag]}${esc(r.suffix||'')}</span></div><input type="range" data-range="${esc(r.flag)}" data-suffix="${esc(r.suffix||'')}" min="${r.min}" max="${r.max}" step="${r.max<=1?'.001':'1'}" value="${state[r.flag]}" style="--pct:${pct}%" aria-label="${esc(r.label)}"></div>`;}
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
  function showMenu(show){menuShown=show; menuWrap.style.display=show?'':'none'; $('#floating').style.display=show?'none':'block';}
  function fit(){const w=stage.clientWidth,h=stage.clientHeight; menuWrap.style.setProperty('--scale',Math.min(1,(w-24)/750,(h-24)/600));}
  function stopIntro(){introTimers.forEach(clearTimeout);introTimers=[];$('#intro').hidden=true;$('#intro').classList.remove('smash');$('#intro-checks').hidden=false;$('#intro-reveal').hidden=true;}
  function later(fn,ms){introTimers.push(setTimeout(fn,ms));}
  function playIntro(){
    stopIntro();showMenu(true); const overlay=$('#intro'); overlay.hidden=false;
    const checks=[['Platform','Desktop'],['Screen size','1280x720'],['Client version','Loaded'],['Game loaded','Loaded'],['Local player','Found'],['PlayerGui','Found'],['Frame rate','60 FPS'],['Network ping','42 ms'],['Input','Keyboard + mouse']];
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
    const action=e.target.closest('[data-action]')?.dataset.action;if(!action)return;
    if(action==='next-mix'){const keys=Object.keys(mixes);applyMix(keys[(keys.indexOf(currentMix)+1)%keys.length]);render();}
    if(action==='intro')playIntro();if(action==='unload')showMenu(false);if(action==='scan'){e.target.textContent='No staff detected';setTimeout(()=>{if(e.target)e.target.textContent='Scan Now';},2000)}
  });
  $('#menu-body').addEventListener('input',e=>{const el=e.target;if(el.dataset.range){state[el.dataset.range]=Number(el.value);const pct=(el.value-el.min)/(el.max-el.min)*100;el.style.setProperty('--pct',pct+'%');$(`[data-value="${el.dataset.range}"]`).textContent=el.value+(el.dataset.suffix||'');}if(el.dataset.color){colors[el.dataset.color][Number(el.dataset.index)]=el.value;el.parentElement.style.background=el.value;updateFigure();}});
  $('#menu-body').addEventListener('change',e=>{const key=e.target.dataset.select;if(!key)return;state[key]=e.target.value;if(key==='NH_Mix'||key==='theme'){applyMix(e.target.value);render();}else updateFigure();});
  $('#replay').addEventListener('click',playIntro);$('#skip-intro').addEventListener('click',stopIntro);$('#close-menu').addEventListener('click',()=>showMenu(false));$('#floating').addEventListener('click',()=>showMenu(true));
  $('#reset').addEventListener('click',()=>{stopIntro();defaults();applyMix(currentMix);render();showMenu(true);menuWrap.style.left='50%';menuWrap.style.top='50%';});
  document.addEventListener('keydown',e=>{if(e.code==='ShiftRight'&&!e.repeat&&!['INPUT','SELECT'].includes(document.activeElement.tagName)){e.preventDefault();showMenu(!menuShown);}});
  let drag=null;$('#drag-handle').addEventListener('pointerdown',e=>{if(e.target.closest('button'))return;const rect=menuWrap.getBoundingClientRect(),parent=stage.getBoundingClientRect();drag={dx:e.clientX-(rect.left+rect.width/2),dy:e.clientY-(rect.top+rect.height/2),left:parent.left,top:parent.top};e.currentTarget.setPointerCapture(e.pointerId)});$('#drag-handle').addEventListener('pointermove',e=>{if(!drag)return;menuWrap.style.left=(e.clientX-drag.left-drag.dx)+'px';menuWrap.style.top=(e.clientY-drag.top-drag.dy)+'px'});$('#drag-handle').addEventListener('pointerup',()=>drag=null);$('#drag-handle').addEventListener('pointercancel',()=>drag=null);
  window.addEventListener('resize',fit);
  const now=new Date();$('#menu-date').textContent=now.toLocaleDateString('en-US',{month:'short',day:'2-digit',year:'numeric'}).replace(',','');$('#hud-time').textContent=now.toLocaleTimeString([],{hour:'2-digit',minute:'2-digit',hour12:false});
  defaults();applyMix(currentMix);render();fit();playIntro();
})();

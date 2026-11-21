import {validateWater,validateBounds} from './guidance-domain.js';
export {researchProfile,acceptCandidate,openCandidateSource,reviewCandidateSource,reviewSource,saveTasteAdvice,acceptAdvice,createHistoricalWater} from './guidance-storage.js';
import {validateMaintenanceRule,validateMaintenanceCompletion} from './maintenance-domain.js';
export {completeMaintenance,saveMaintenanceRule} from './maintenance-storage.js';
import {validateGrinder,validateMachine,validateRecipe,validateRetention} from './domain.js';
import {fields,extensionFields,matches} from './schema.js';
import {newEntity} from './domain.js';
import {validateBrew} from './brew-domain.js';
import {recordBrewConsumption} from './brew-storage.js';
export {createBrewDraft,startBrew,timerAction,completeBrew,reviseBrew,abortBrew,repeatBrew} from './brew-storage.js';
import {balance,bagState} from './inventory-domain.js';
export const types=['machines','grinders','retentionMeasurements','roasters','coffees','batches','bags','stockMovements','recipes','brews','tastes','waterProfiles','maintenanceRules','maintenanceCompletions','sources','recommendations'];
export const defaults={id:'00000000-0000-4000-8000-000000000001',createdAt:'2026-11-16T00:00:00Z',updatedAt:'2026-11-16T00:00:00Z',revision:1,archived:false,locale:'de-CH',timezone:'Europe/Zurich',theme:'system',defaultMethod:'espresso',defaultMachineId:null,defaultGrinderId:null,defaultWaterProfileId:null};
export const empty=()=>({schemaVersion:1,exportedAt:new Date().toISOString(),settings:{...defaults},entities:Object.fromEntries(types.map(t=>[t,[]]))});
const fail=(code,field,message)=>({ok:false,error:{code,field,message}});
const validHttps=value=>{try{const url=new URL(value);return url.protocol==='https:'&&!!url.hostname&&!/\s/.test(value);}catch{return false;}};
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const refs={waterSourceId:['sources'],acceptedRecipeId:['recipes'],targetRecipeId:['recipes'],machineId:['machines'],grinderId:['grinders'],roasterId:['roasters'],coffeeId:['coffees'],batchId:['batches'],bagId:['bags'],brewId:['brews'],ruleId:['maintenanceRules'],sourceId:['sources'],deviceId:['machines','grinders'],completionId:['maintenanceCompletions'],defaultMachineId:['machines'],defaultGrinderId:['grinders'],defaultWaterProfileId:['waterProfiles']};
export function validate(data){
 const bad=(p,m)=>fail('VALIDATION',p,m); if(data?.schemaVersion!==1)return fail('UNSUPPORTED_VERSION','schemaVersion','Dateiformat nicht unterstützt');
 if(!data.settings||typeof data.settings!=='object'||!data.entities||typeof data.entities!=='object')return bad('entities','Sammlung fehlt');
 if(data.settings.locale!=='de-CH'||data.settings.timezone!=='Europe/Zurich'||!['light','dark','system'].includes(data.settings.theme)||!['espresso','filter'].includes(data.settings.defaultMethod))return bad('settings','Ungültige Einstellungen');
 for(const key of Object.keys(defaults)){if(!matches(data.settings[key],key.endsWith('Id')?'id?':key==='revision'?'integer':key==='archived'?'boolean':key.endsWith('At')?'timestamp':key==='id'?'id':'text'))return bad('settings.'+key,'Ungültiges oder fehlendes Feld');}
 if(data.settings.revision<1)return bad('settings.revision','Ungültige Revision');
 if(types.some(t=>Array.isArray(data.entities[t])&&data.entities[t].some(e=>e?.id===data.settings.id)))return bad('settings.id','Doppelte ID');
 const ids=new Set([data.settings.id]); for(const t of types){if(!Array.isArray(data.entities[t]))return bad(`entities.${t}`,'Liste fehlt'); for(const [i,e] of data.entities[t].entries()){if(!e||typeof e!=='object'||Array.isArray(e))return bad(`entities.${t}[${i}]`,'Eintrag muss ein Objekt sein');const p=`entities.${t}[${i}]`;for(const [key,rule] of Object.entries(fields[t])){if(!matches(e[key],rule))return bad(p+'.'+key,'Ungültiges oder fehlendes Feld');}if(!uuid.test(e.id)||ids.has(e.id))return bad(p+'.id','Ungültige oder doppelte ID');ids.add(e.id);if(!Number.isInteger(e.revision)||e.revision<1||typeof e.archived!=='boolean'||!matches(e.createdAt,'timestamp')||!matches(e.updatedAt,'timestamp'))return bad(p,'Ungültige gemeinsame Felder');if(['machines','grinders','roasters','coffees','recipes','waterProfiles'].includes(t)&&(!(typeof e.name==='string')||!e.name.trim()||e.name.length>120))return bad(p+'.name','Name erforderlich');}}
 function walk(v,p){if(v===null)return null;if(Array.isArray(v)){for(let i=0;i<v.length;i++){const r=walk(v[i],`${p}[${i}]`);if(r)return r;}return null;}if(typeof v!=='object')return null;for(const [k,x] of Object.entries(v)){const q=p?p+'.'+k:k;if(x===undefined)return bad(q,'Wert fehlt');if(refs[k]&&!(k==='ruleId'&&p.includes('recommendations'))&&x!==null&&!refs[k].some(t=>data.entities[t].some(e=>e.id===x)))return bad(q,'Referenz nicht gefunden');if((k==='url'||k==='website')&&x!==null&&(typeof x!=='string'||x.length>2048||!validHttps(x)))return bad(q,'HTTPS-Adresse erforderlich');if(typeof x==='string'&&((k==='notes'&&x.length>4000)||(/name/i.test(k)&&x.length>120)))return bad(q,'Text zu lang');if(typeof x==='number'){let max=/Seconds$/.test(k)?86400:/Days$|restDays|reorderLeadDays|safetyDays/.test(k)?365:k==='pH'?14:/MgL/.test(k)?10000:k==='temperatureC'?100:k==='pressureBar'?20:k==='ratio'?100:k==='doseG'?1000:1000000;if(p.endsWith('usageSnapshot')&&p.includes('maintenanceCompletions'))max=Number.MAX_SAFE_INTEGER/10;if(!Number.isFinite(x)||Math.abs(x)>max||(x<0&&!['amountG','retainedG','min','max','numericValue'].includes(k))||((/G$|C$/.test(k))&&Math.abs(x*10-Math.round(x*10))>1e-7))return bad(q,'Ungültiger Zahlenwert');}const r=walk(x,q);if(r)return r;}return null;}
 const r=walk({settings:data.settings,entities:data.entities},'');if(r)return r;
 if(data.entities.brews.filter(b=>['running','interrupted'].includes(b.status)).length>1)return bad('entities.brews','Ein Bezug läuft bereits');
 for(const t of types)for(const [i,e] of data.entities[t].entries()){if(!e||typeof e!=='object'||Array.isArray(e))return bad(`entities.${t}[${i}]`,'Eintrag muss ein Objekt sein');const p=`entities.${t}[${i}]`;
 for(const [key,rule] of Object.entries(extensionFields[t]||{}))if(key in e&&!matches(e[key],rule))return bad(p+'.'+key,'Ungültiges Feld');
 if(t==='waterProfiles'){const c=validateWater(e);if(!c.ok)return bad(p+'.'+c.error.field,c.error.message);}
 if(t==='machines'&&e.waterLimits){const c=validateBounds(e.waterLimits);if(!c.ok)return bad(p+'.waterLimits.'+c.error.field,c.error.message);}
 if(t==='maintenanceRules'||t==='maintenanceCompletions'){const check=t==='maintenanceRules'?validateMaintenanceRule(e,data):validateMaintenanceCompletion(e,data);if(!check.ok)return bad(p+'.'+check.error.field,check.error.message);}
 if(t==='brews'){const check=validateBrew(e);if(!check.ok)return bad(p+'.'+check.error.field,check.error.message);}
 if(['machines','grinders','recipes','retentionMeasurements'].includes(t)){const check=t==='machines'?validateMachine(e):t==='grinders'?validateGrinder(e):t==='recipes'?validateRecipe(e,data.entities):validateRetention(e);if(!check.ok)return bad(p+'.'+check.error.field,check.error.message);}
 if(e.sourceIds&&!e.sourceIds.every(id=>data.entities.sources.some(s=>s.id===id)))return bad(p+'.sourceIds','Referenz nicht gefunden');
 if(t==='bags'&&e.initialG<0)return bad(p+'.initialG','Anfangsbestand darf nicht negativ sein');
 if(t==='bags'&&e.readyOn!==undefined&&e.readyOn!==null&&!matches(e.readyOn,'date'))return bad(p+'.readyOn','Ungültiges Datum');
 if(t==='bags'&&e.storage==='ambient'&&e.thawedOn&&!e.readyOn)return bad(p+'.readyOn','Bereit ab nach dem Auftauen bestätigen');
 if(t==='coffees'&&e.manualDailyUseG!==undefined&&e.manualDailyUseG!==null&&(!Number.isFinite(e.manualDailyUseG)||e.manualDailyUseG<=0||e.manualDailyUseG>1000000))return bad(p+'.manualDailyUseG','Positive Verbrauchsprognose erforderlich');
 if(t==='stockMovements'&&e.kind==='receipt'&&e.amountG<0)return bad(p+'.amountG','Wareneingang darf nicht negativ sein');
 if(t==='stockMovements'&&['brew','purge','waste'].includes(e.kind)&&e.amountG>0)return bad(p+'.amountG','Verbrauch muss als Abgang erfasst werden');
 if(t==='stockMovements'&&e.kind==='adjustment'&&!e.reason?.trim())return bad(p+'.reason','Grund der Korrektur erforderlich');
 if(t==='recipes'&&(e.doseG<=0||e.ratio<=0))return bad(p+'.doseG','Dosis und Verhältnis müssen positiv sein');
 if(t==='recipes')for(const [j,step] of e.steps.entries())if(!step||!Number.isInteger(step.offsetSeconds)||step.offsetSeconds<0||step.offsetSeconds>86400||typeof step.incrementalWaterG!=='number'||step.incrementalWaterG<=0||typeof step.instruction!=='string'||(j>0&&step.offsetSeconds<e.steps[j-1].offsetSeconds))return bad(p+`.steps[${j}]`,'Ungültiger Filterschritt');
 if(t==='coffees'&&e.preferredRestDays!==null)for(const [key,value] of Object.entries(e.preferredRestDays))if(!['espresso','filter'].includes(key)||(value!==null&&(!Number.isInteger(value)||value<0||value>365)))return bad(p+'.preferredRestDays.'+key,'Ungültige Ruhetage');
 if(t==='recipes'&&e.method==='filter'&&(e.steps.length<1||e.steps.length>30))return bad(p+'.steps','1–30 Schritte erforderlich');
 if(t==='maintenanceRules'&&![e.days,e.shots,e.throughputG,e.brewSeconds].some(v=>v>0))return bad(p+'.days','Mindestens eine positive Grenze angeben');
 if(t==='tastes')for(const key of ['liking','sour','bitter','sweet','body','astringent'])if(e[key]!==null&&(e[key]<(key==='liking'?1:0)||e[key]>5))return bad(p+'.'+key,'Bewertung ausserhalb des Bereichs');
 if(t==='brews'){if(e.method==='espresso'&&e.pouredWaterG!==null)return bad(p+'.pouredWaterG','Für Espresso nicht vorgesehen');if(e.method==='filter'&&e.yieldG!==null)return bad(p+'.yieldG','Für Filter nicht vorgesehen');if(e.status==='completed'&&(e.doseG<=0||(e.method==='espresso'?e.yieldG:e.pouredWaterG)<=0))return bad(p+'.doseG','Messwerte fehlen');for(const [j,a] of e.allocations.entries())if(!data.entities.bags.some(b=>b.id===a.bagId)||!['doseG','purgeG','wasteG'].every(k=>typeof a[k]==='number'&&a[k]>=0))return bad(p+`.allocations[${j}]`,'Ungültige Zuteilung');}
 }
 for(const [i,b] of data.entities.bags.entries()){const n=data.entities.stockMovements.filter(m=>m.bagId===b.id).reduce((s,m)=>s+Math.round(m.amountG*10),0);if(n<0)return bad(`entities.bags[${i}].balance`,'Bestand darf nicht negativ sein');}
 return {ok:true,data,revision:data.settings.revision};
}
export async function previewFile(file){if(file.size>20971520)return fail('VALIDATION','file','Datei zu gross: maximal 20 MiB (20 971 520 Bytes).');try{return validate(JSON.parse(await file.text()));}catch{return fail('VALIDATION','file','Dateiformat nicht unterstützt');}}
let connection;
async function db(){if(!connection)connection= new Promise((resolve,reject)=>{const r=indexedDB.open('kaffeejournal',1);r.onupgradeneeded=()=>r.result.createObjectStore('collection');r.onsuccess=()=>resolve(r.result);r.onerror=()=>{connection=null;reject(r.error);};});return connection;}
export async function read(){try{const d=await db();return await new Promise((resolve,reject)=>{const r=d.transaction('collection').objectStore('collection').get('data');r.onsuccess=()=>resolve({ok:true,data:r.result||empty(),revision:r.result?.settings.revision||1});r.onerror=()=>reject(r.error);});}catch{return fail('STORAGE_UNAVAILABLE',null,'Lokales Speichern nicht verfügbar');}}
export async function mutate(change){try{const d=await db();return await new Promise(resolve=>{const tx=d.transaction('collection','readwrite');const s=tx.objectStore('collection');let result;const r=s.get('data');r.onsuccess=()=>{const data=r.result||empty();try{result=change(data);}catch{result=fail('VALIDATION',null,'Ungültige Daten');}if(result.ok)s.put(result.data,'data');};tx.oncomplete=()=>{resolve(result);if(result.ok&&typeof BroadcastChannel!=='undefined'){const c=new BroadcastChannel('kaffeejournal');c.postMessage('updated');c.close();}};tx.onerror=()=>resolve(fail('STORAGE_UNAVAILABLE',null,'Lokales Speichern nicht verfügbar'));tx.onabort=tx.onerror;});}catch{return fail('STORAGE_UNAVAILABLE',null,'Lokales Speichern nicht verfügbar');}}
export function saveEntity(type,entity,expectedRevision){return mutate(data=>{const list=type==='settings'?[data.settings]:data.entities[type];if(!list)return fail('VALIDATION','type','Unbekannter Eintrag');if(type==='maintenanceCompletions')return fail('VALIDATION','type','Pflegehistorie ist unveränderlich');if(type==='stockMovements')return fail('VALIDATION','type','Bestandsjournal ist unveränderlich');const old=list.find(e=>e.id===entity.id);if((old?.revision??null)!==expectedRevision)return fail('CONFLICT','revision','Eintrag wurde geändert. Entwurf bleibt erhalten. Neu laden.');if(type==='maintenanceRules'&&old&&(old.deviceId!==entity.deviceId||old.completionId!==entity.completionId))return fail('VALIDATION','deviceId','Gerät und Ausgangsstand bleiben bei dieser Regel');if(type==='brews'&&((old&&old.status!=='draft')||entity.status!=='draft'||(old&&JSON.stringify(old.recipeSnapshot)!==JSON.stringify(entity.recipeSnapshot))))return fail('VALIDATION','status','Bezug über Bezugsbefehle ändern');if(type==='bags')return fail('VALIDATION','initialG','Bestandsänderung über Lagerjournal erfassen');const value={...entity,revision:(old?.revision||0)+1,createdAt:old?.createdAt||new Date().toISOString(),updatedAt:new Date().toISOString()};if(type==='settings')data.settings=value;else if(old)list[list.indexOf(old)]=value;else list.push(value);const v=validate(data);return v.ok?{ok:true,data,revision:value.revision}:v;});}
const canonical=value=>JSON.stringify(value,(_,v)=>v&&typeof v==='object'&&!Array.isArray(v)?Object.fromEntries(Object.keys(v).sort().map(k=>[k,v[k]])):v);
function replay(data,operationId,payload){if(!uuid.test(operationId))return fail('VALIDATION','operationId','Ungültige Vorgangs-ID');const old=data.entities.stockMovements.find(m=>m.operationId===operationId);if(!old)return null;return old.operationPayload===canonical(payload)&&old.operationResult?{ok:true,data,revision:old.operationRevision??1,operationResult:old.operationResult}:fail('CONFLICT','operationId','Vorgangs-ID wurde mit anderem Inhalt verwendet');}
function operationOutcome(data,operationId,revision,outcome){for(const m of data.entities.stockMovements.filter(m=>m.operationId===operationId))m.operationResult=structuredClone(outcome);return {ok:true,data,revision,operationResult:outcome};}
const publicOutcome=result=>result.ok?{ok:true,data:result.operationResult,revision:result.revision}:result;
function appendMovement(data,values,operationId,payload,revision){data.entities.stockMovements.push(newEntity({bagId:values.bagId,amountG:values.amountG,kind:values.kind,occurredAt:new Date().toISOString(),brewId:values.brewId??null,operationId,reason:values.reason??null,operationPayload:canonical(payload),operationRevision:revision}));}
export function saveBag(bag,batch,expectedRevision,operationId,reason=null,targetBalance=null){const payload={command:'saveBag',bag,batch,expectedRevision,reason,targetBalance};return mutate(data=>{
 const repeated=replay(data,operationId,payload);if(repeated)return repeated;
 const old=data.entities.bags.find(b=>b.id===bag.id);if((old?.revision??null)!==expectedRevision)return fail('CONFLICT','revision','Eintrag wurde geändert. Entwurf bleibt erhalten. Neu laden.');
 if(old?.storage==='frozen'&&bag.storage==='ambient'&&(!bag.thawedOn||!bag.readyOn))return fail('VALIDATION','readyOn','Bereit ab nach dem Auftauen bestätigen');
 if(batch){if(data.entities.batches.some(b=>b.id===batch.id))return fail('CONFLICT','batchId','Charge bereits vorhanden');data.entities.batches.push(structuredClone(batch));}
 const value={...structuredClone(bag),revision:(old?.revision??0)+1,createdAt:old?.createdAt??bag.createdAt,updatedAt:new Date().toISOString()};
 if(old&&targetBalance!==null)value.initialG=old.initialG;
 const delta=old?(targetBalance===null?Math.round(value.initialG*10)-Math.round(old.initialG*10):Math.round(targetBalance*10)-Math.round(balance(data,old.id)*10)):Math.round(value.initialG*10);
 if(targetBalance!==null&&(!Number.isFinite(targetBalance)||targetBalance<0||targetBalance>1000000||Math.abs(targetBalance*10-Math.round(targetBalance*10))>1e-7))return fail('VALIDATION','targetBalance','Ungültiger Bestand');
 if(old&&delta!==0&&!reason?.trim())return fail('VALIDATION','reason','Grund der Korrektur erforderlich');
 if(old)data.entities.bags[data.entities.bags.indexOf(old)]=value;else data.entities.bags.push(value);
 // Zero movements also retain idempotency for metadata-only bag operations.
 appendMovement(data,{bagId:value.id,amountG:delta/10,kind:old?'adjustment':'receipt',reason:old?(reason?.trim()||'Beuteldaten aktualisiert'):null},operationId,payload,value.revision);
 const outcome={operationId,bag:structuredClone(value),batch:structuredClone(batch)};const result=validate(data);return result.ok?operationOutcome(data,operationId,value.revision,outcome):result;
 }).then(publicOutcome);}
export function recordConsumption(brewId,operationId,allocations,expectedRevision,options={}){if(brewId!==null)return recordBrewConsumption(brewId,operationId,allocations,expectedRevision,options);const payload={command:'recordConsumption',brewId,allocations,expectedRevision,options};return mutate(data=>{
 const repeated=replay(data,operationId,payload);if(repeated)return repeated;
 const brew=brewId===null?null:data.entities.brews.find(b=>b.id===brewId);if(brewId!==null&&!brew)return fail('NOT_FOUND','brewId','Eintrag nicht gefunden');if((brew?.revision??null)!==expectedRevision)return fail('CONFLICT','revision','Eintrag wurde geändert. Entwurf bleibt erhalten. Neu laden.');
 if(!Array.isArray(allocations)||!allocations.length)return fail('VALIDATION','allocations','Vollständige Zuteilung erforderlich');
 let total=0;const ids=new Set();for(const [i,a] of allocations.entries()){
 if(!a||typeof a!=='object')return fail('VALIDATION',`allocations[${i}]`,'Ungültige Zuteilung');
 const bag=data.entities.bags.find(b=>b.id===a.bagId);if(!bag||bag.archived||ids.has(a.bagId))return fail('VALIDATION',`allocations[${i}].bagId`,'Ungültiger oder archivierter Beutel');ids.add(a.bagId);
 if(brew?.recipeSnapshot?.coffeeId&&!data.entities.batches.some(batch=>batch.id===bag.batchId&&batch.coffeeId===brew.recipeSnapshot.coffeeId))return fail('VALIDATION',`allocations[${i}].bagId`,'Beutel gehört nicht zum bestätigten Kaffee');
 const state=bagState(data,bag,brew?.method??options.method??data.settings.defaultMethod,options.today);if(state.status==='frozen')return fail('VALIDATION','storage','Gefrorene Bohnen zuerst auftauen');if(state.status!=='ready'&&!options.override)return fail('VALIDATION','readyOn','Trotzdem verwenden bestätigen');
 let used=0;for(const key of ['doseG','purgeG','wasteG']){if(!Number.isFinite(a[key])||a[key]<0||a[key]>1000000||Math.abs(a[key]*10-Math.round(a[key]*10))>1e-7)return fail('VALIDATION',`allocations[${i}].${key}`,'Ungültige Menge');used+=Math.round(a[key]*10);}
 if(used===0)return fail('VALIDATION',`allocations[${i}]`,'Positive Verbrauchsmenge je Beutel erforderlich');
 if(used>Math.round(balance(data,bag.id)*10))return fail('INSUFFICIENT_STOCK','allocations','Bestand reicht nicht aus. Zuteilung erneut prüfen.');total+=used;
 }
 if(total<=0)return fail('VALIDATION','allocations','Positive Verbrauchsmenge erforderlich');
 if(brew){
 const sum=(rows,key)=>rows.reduce((n,a)=>n+Math.round(a[key]*10),0);
 if(sum(allocations,'doseG')!==Math.round(brew.doseG*10))return fail('VALIDATION','allocations.doseG','Zuteilung entspricht nicht der bestätigten Dosis');
 for(const key of ['purgeG','wasteG'])if(sum(allocations,key)!==sum(brew.allocations,key))return fail('VALIDATION','allocations.'+key,'Zuteilung entspricht nicht dem bestätigten Verbrauch');
 }
 const revision=(brew?.revision??0)+1;for(const a of allocations)for(const [key,kind] of [['doseG','brew'],['purgeG','purge'],['wasteG','waste']])if(a[key]>0)appendMovement(data,{bagId:a.bagId,amountG:-a[key],kind,brewId},operationId,payload,revision);
 if(brew){brew.allocations=structuredClone(allocations);brew.revision=revision;brew.updatedAt=new Date().toISOString();}
 const result=validate(data);return result.ok?operationOutcome(data,operationId,revision,{operationId,brewId,allocations:structuredClone(allocations)}):result;
 }).then(publicOutcome);}
export function replace(data){const v=validate(data);if(!v.ok)return Promise.resolve(v);const imported=structuredClone(data);for(const source of imported.entities.sources){source.status='stale';source.reviewedAt=null;}return mutate(()=>({ok:true,data:imported,revision:imported.settings.revision}));}
export function backup(data){return {...structuredClone(data),exportedAt:new Date().toISOString()};}
export const backupName=(date=new Date())=>`coffee-backup-${new Intl.DateTimeFormat('sv-SE',{timeZone:'Europe/Zurich'}).format(date)}.json`;

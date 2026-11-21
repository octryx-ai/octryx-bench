import {newEntity,starter,scaleSteps,validateRecipe,purgeSuggestion} from './domain.js';
import {allocateStock,coffeeBags,orderedBags} from './inventory-domain.js';
export const brewError=(code,field,message)=>({ok:false,error:{code,field,message}});
export const quantities=['doseG','purgeG','wasteG'];
export const sumQuantity=(rows,key)=>Array.isArray(rows)?rows.reduce((n,a)=>n+Math.round(a?.[key]*10),0)/10:NaN;
export function elapsedSeconds(brew,now=new Date().toISOString()){
 if(!brew.startedAt)return 0;const end=Date.parse(brew.timer?.stoppedAt??now);let paused=0;
 for(const p of brew.timer?.pauses??[])paused+=Math.max(0,Date.parse(p.endedAt??brew.timer?.stoppedAt??now)-Date.parse(p.startedAt));
 return Math.max(0,Math.floor((end-Date.parse(brew.startedAt)-paused)/1000));
}
export function purgeFor(data,grinderId,coffeeId,now=new Date().toISOString(),selectedIds=null){
 const grinder=data.entities.grinders.find(g=>g.id===grinderId);if(!grinder)return {amountG:0,idleHours:0,changedBatch:false};
 const bag=orderedBags(data,coffeeBags(data,coffeeId).filter(b=>b.storage==='ambient'&&(!selectedIds||selectedIds.includes(b.id))))[0];
 const previous=data.entities.brews.filter(b=>b.grinderSnapshot?.id===grinderId&&b.lastConfirmedAt).sort((a,b)=>b.lastConfirmedAt.localeCompare(a.lastConfirmedAt))[0];
 const lastBatchId=grinder.lastBatchId??data.entities.bags.find(b=>b.id===previous?.allocations.at(-1)?.bagId)?.batchId??null;
 const idleHours=grinder.lastUsedAt?Math.max(0,(Date.parse(now)-Date.parse(grinder.lastUsedAt))/3600000):0;
 const changedBatch=!!(lastBatchId&&bag&&lastBatchId!==bag.batchId);
 return {amountG:purgeSuggestion(grinder,{idleHours,changedBatch}),idleHours,changedBatch};
}
const finite=(v,min,max,integer=false)=>Number.isFinite(v)&&v>=min&&v<=max&&(!integer||Number.isInteger(v));
export function validateActuals(method,a){
 const bad=(field,message)=>brewError('VALIDATION',field,message);
 if(!a||typeof a!=='object')return bad('actuals','Messwerte fehlen');
 if(method==='espresso'&&a.pouredWaterG!==null)return bad('pouredWaterG','Für Espresso nicht vorgesehen');
 if(method==='filter'&&a.yieldG!==null)return bad('yieldG','Für Filter nicht vorgesehen');
 if(!finite(a.doseG,0.1,1000)||Math.abs(a.doseG*10-Math.round(a.doseG*10))>1e-7)return bad('doseG','Positive Dosis erforderlich');
 const key=method==='espresso'?'yieldG':'pouredWaterG';if(!finite(a[key],0.1,1000000)||Math.abs(a[key]*10-Math.round(a[key]*10))>1e-7)return bad(key,method==='espresso'?'Positive Getränkemenge erforderlich':'Positive Wassermenge erforderlich');
 if(a.durationSeconds!==null&&!finite(a.durationSeconds,0,86400,true))return bad('durationSeconds','Ungültige Zeit – Korrektur erforderlich');
 if(a.notes!==null&&(typeof a.notes!=='string'||a.notes.length>4000))return bad('notes','Maximal 4000 Zeichen');
 return {ok:true,data:a};
}
export function validateBrew(b){
 if(b.status==='completed'){const result=validateActuals(b.method,b);if(!result.ok)return result;if(sumQuantity(b.allocations,'doseG')!==b.doseG)return brewError('VALIDATION','allocations.doseG','Zuteilung entspricht nicht der tatsächlichen Dosis');}
 const ids=new Set();for(const [i,a] of b.allocations.entries()){if(!a||ids.has(a.bagId)||quantities.some(k=>!finite(a[k],0,1000000)))return brewError('VALIDATION',`allocations[${i}]`,'Ungültige oder doppelte Zuteilung');ids.add(a.bagId);}
 if(b.timer){const t=b.timer;if(!Array.isArray(t.pauses)||!Number.isInteger(t.stepIndex)||t.stepIndex<0||t.stepIndex>(b.recipeSnapshot.steps?.length??0))return brewError('VALIDATION','timer','Ungültiger Timer');
 let end=b.startedAt?Date.parse(b.startedAt):null;for(const p of t.pauses){if(!p||!Number.isFinite(Date.parse(p.startedAt))||(p.endedAt!==null&&!Number.isFinite(Date.parse(p.endedAt)))||end===null||Date.parse(p.startedAt)<end||(p.endedAt!==null&&Date.parse(p.endedAt)<Date.parse(p.startedAt)))return brewError('VALIDATION','timer.pauses','Ungültige Pausenzeiten');end=p.endedAt===null?Infinity:Date.parse(p.endedAt);}
 if(t.stoppedAt!==null&&(!Number.isFinite(Date.parse(t.stoppedAt))||(b.startedAt&&Date.parse(t.stoppedAt)<Date.parse(b.startedAt))))return brewError('VALIDATION','timer.stoppedAt','Ungültige Stoppzeit');}
 if(b.durationCorrection&&(!finite(b.durationCorrection.correctedSeconds,0,86400,true)||!b.durationCorrection.reason?.trim()))return brewError('VALIDATION','durationCorrection','Grund der Zeitkorrektur erforderlich');
 return {ok:true,data:b};
}
export function draftFromSetup(data,setup){
 const bad=(field,message)=>brewError('VALIDATION',field,message);const coffee=data.entities.coffees.find(c=>c.id===setup.coffeeId&&!c.archived);if(!coffee)return bad('coffeeId','Keine Bohnen vorhanden');
 const repeat=setup.repeatSnapshot??null;
 const pick=(type,key,snapshot)=>setup[key]?repeat&&repeat[snapshot]?.id===setup[key]?structuredClone(repeat[snapshot]):structuredClone(data.entities[type].find(e=>e.id===setup[key]&&!e.archived)??null):null;
 const machine=pick('machines','machineId','machineSnapshot'),grinder=pick('grinders','grinderId','grinderSnapshot'),water=pick('waterProfiles','waterProfileId','waterSnapshot');
 for(const [key,value] of [['machineId',machine],['grinderId',grinder],['waterProfileId',water]])if(setup[key]&&!value)return bad(key,'Eintrag nicht gefunden oder archiviert');
 const saved=setup.recipeId?data.entities.recipes.find(r=>r.id===setup.recipeId&&!r.archived):null;if(setup.recipeId&&!saved&&!repeat)return bad('recipeId','Rezept nicht gefunden');
 const recipe={...(repeat?.recipeSnapshot??saved??starter(setup.method)),method:setup.method,machineId:machine?.id??null,grinderId:grinder?.id??null,setting:setup.setting??null,doseG:setup.doseG,ratio:setup.ratio,temperatureC:setup.temperatureC??null,pressureBar:setup.pressureBar??null,preinfusionSeconds:setup.preinfusionSeconds??null};
 if(setup.method==='filter'){const base=repeat?.recipeSnapshot??saved??starter('filter');const scaled=scaleSteps(base.steps,base.doseG,setup.doseG,setup.ratio);if(!scaled.ok)return scaled;recipe.steps=scaled.data;}
 if(!['espresso','filter'].includes(setup.method))return bad('method','Ungültige Methode');
 const checked=validateRecipe(recipe,{...data.entities,machines:machine?[machine]:[],grinders:grinder?[grinder]:[]});if(!checked.ok)return checked;
 if(!finite(setup.doseG,0.1,1000)||!finite(setup.ratio,0.1,100))return bad('doseG','Dosis oder Verhältnis ausserhalb des zulässigen Bereichs');
 for(const [key,max,integer] of [['temperatureC',100,false],['pressureBar',20,false],['preinfusionSeconds',86400,true]])if(recipe[key]!==null&&!finite(recipe[key],0,max,integer))return bad(key,'Wert liegt ausserhalb der Gerätevorgaben');
 const allocated=allocateStock(data,{coffeeId:coffee.id,doseG:setup.doseG,purgeG:setup.purgeG,wasteG:setup.wasteG,method:setup.method,selectedIds:setup.selectedIds??null,override:!!setup.override});if(!allocated.ok)return allocated;
 const roaster=data.entities.roasters.find(r=>r.id===coffee.roasterId);const b=newEntity({method:setup.method,status:'draft',startedAt:null,durationSeconds:null,recipeSnapshot:structuredClone(recipe),machineSnapshot:machine,grinderSnapshot:grinder,settingSnapshot:structuredClone(recipe.setting),waterSnapshot:water,doseG:setup.doseG,yieldG:null,pouredWaterG:null,allocations:allocated.data,purgeReason:setup.purgeReason??null,notes:null,parameterSnapshot:{coffeeId:coffee.id,coffeeName:coffee.name,roasterName:roaster?.name??null,coffeeSnapshot:structuredClone(coffee),batchSnapshots:data.entities.batches.filter(batch=>allocated.data.some(a=>data.entities.bags.some(bag=>bag.id===a.bagId&&bag.batchId===batch.id))).map(x=>structuredClone(x)),purgeG:setup.purgeG,wasteG:setup.wasteG,stockOverrideConfirmed:!!setup.override,recipeId:setup.recipeId??null,preserveSnapshots:!!repeat},timer:{pauses:[],stoppedAt:null,stepIndex:0},lastConfirmedAt:null,operations:[]});
 return {ok:true,data:b,revision:1};
}

import {localDay} from './inventory-domain.js';
export const maintenanceDefaults={deviceId:null,name:'',days:null,shots:null,throughputG:null,brewSeconds:null,sourceId:null,completionId:null};
export const maintenanceError=(field,message,code='VALIDATION')=>({ok:false,error:{code,field,message}});
export const deviceFor=(data,id)=>[...data.entities.machines,...data.entities.grinders].find(d=>d.id===id);
const unitKeys=['shots','throughputG','brewSeconds'];
export function cumulativeUsage(data,deviceId){
 let shots=0,brewSeconds=0,throughputTenths=0;const brews=new Map(data.entities.brews.map(b=>[b.id,b])),doseByBrew=new Map();for(const m of data.entities.stockMovements)if(m.kind==='brew'||(m.kind==='reversal'&&m.reversalOfKind==='brew'))doseByBrew.set(m.brewId,(doseByBrew.get(m.brewId)??0)-Math.round(m.amountG*10));
 for(const b of brews.values())if(b.machineSnapshot?.id===deviceId&&['completed','aborted'].includes(b.status)){
  const confirmed=b.status==='completed'||(doseByBrew.get(b.id)??0)>0;
  if(confirmed&&b.method==='espresso')shots++;
  if((b.status==='completed'||b.startedAt)&&Number.isFinite(b.durationSeconds))brewSeconds+=b.durationSeconds;
 }
 for(const m of data.entities.stockMovements){const b=brews.get(m.brewId);if(b?.grinderSnapshot?.id!==deviceId)continue;if(['brew','purge','waste'].includes(m.kind)||(m.kind==='reversal'&&['brew','purge','waste'].includes(m.reversalOfKind)))throughputTenths-=Math.round(m.amountG*10);}
 return {shots,throughputG:Math.max(0,throughputTenths)/10,brewSeconds};
}
const dayNumber=date=>Date.parse(date+'T12:00:00Z')/86400000;
export function maintenanceState(data,rule,now=new Date()){
 const completion=data.entities.maintenanceCompletions.find(c=>c.id===rule.completionId&&c.ruleId===rule.id),cumulative=cumulativeUsage(data,rule.deviceId),baseline=completion?.usageSnapshot??{};
 const usage=Object.fromEntries(unitKeys.map(k=>[k,Math.max(0,Math.round((cumulative[k]-(baseline[k]??0))*10)/10)]));
 usage.days=Math.max(0,Math.round(dayNumber(localDay(now))-dayNumber(localDay(new Date(completion?.completedAt??rule.createdAt)))));
 const reasons=['days','shots','throughputG','brewSeconds'].filter(k=>rule[k]>0&&usage[k]>=rule[k]);return {rule,device:deviceFor(data,rule.deviceId),completion,cumulative,usage,reasons,due:reasons.length>0};
}
export function maintenanceRows(data,now=new Date()) {return data.entities.maintenanceRules.filter(r=>!r.archived).map(r=>maintenanceState(data,r,now)).sort((a,b)=>Number(b.due)-Number(a.due)||(a.device?.name??'').localeCompare(b.device?.name??'','de-CH')||a.rule.name.localeCompare(b.rule.name,'de-CH')||a.rule.id.localeCompare(b.rule.id));}
export function matchingSource(source,device){if(!source||!device?.manufacturer?.trim())return false;const manufacturer=device.manufacturer.trim().toLocaleLowerCase('de-CH');return source.publisher?.trim().toLocaleLowerCase('de-CH')===manufacturer&&source.appliesTo?.toLocaleLowerCase('de-CH').includes(manufacturer)&&(!device.model||source.appliesTo.toLocaleLowerCase('de-CH').includes(device.model.trim().toLocaleLowerCase('de-CH')));}
export function validateMaintenanceRule(rule,data){
 const device=deviceFor(data,rule.deviceId);if(!device)return maintenanceError('deviceId','Gerät auswählen');if(typeof rule.name!=='string'||!rule.name.trim()||rule.name.trim().length>120)return maintenanceError('name','Aufgabe erforderlich');
 if(!['days','shots','throughputG','brewSeconds'].some(k=>Number.isFinite(rule[k])&&rule[k]>0))return maintenanceError('days','Mindestens eine positive Grenze angeben');
 for(const [key,max,integer] of [['days',365,true],['shots',1000000,true],['throughputG',1000000,false],['brewSeconds',86400,true]])if(rule[key]!==null&&(!Number.isFinite(rule[key])||rule[key]<0||rule[key]>max||(integer&&!Number.isInteger(rule[key]))||(!integer&&Math.abs(rule[key]*10-Math.round(rule[key]*10))>1e-7)))return maintenanceError(key,'Wert ausserhalb des zulässigen Bereichs');
 if(rule.completionId&&!data.entities.maintenanceCompletions.some(c=>c.id===rule.completionId&&c.ruleId===rule.id))return maintenanceError('completionId','Pflegeabschluss gehört nicht zu dieser Regel');
 if(rule.sourceId){const source=data.entities.sources.find(s=>s.id===rule.sourceId);if(!matchingSource(source,device))return maintenanceError('sourceId','Passende Herstellerquelle erforderlich; alternativ Benutzerdefiniert wählen');}
 return {ok:true,data:rule};
}
export function validateMaintenanceCompletion(c,data){const rule=data.entities.maintenanceRules.find(r=>r.id===c.ruleId);if(!rule)return maintenanceError('ruleId','Pflegeregel nicht gefunden');for(const key of unitKeys)if(!Number.isFinite(c.usageSnapshot?.[key])||c.usageSnapshot[key]<0||(key!=='throughputG'&&!Number.isSafeInteger(c.usageSnapshot[key]))||(key==='throughputG'&&!Number.isSafeInteger(Math.round(c.usageSnapshot[key]*10))))return maintenanceError('usageSnapshot.'+key,'Ungültiger Ausgangsstand');if(c.usageSnapshot.deviceId&&c.usageSnapshot.deviceId!==rule.deviceId)return maintenanceError('usageSnapshot.deviceId','Ausgangsstand gehört nicht zu diesem Gerät');return {ok:true,data:c};}

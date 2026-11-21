import {mutate,validate} from './storage.js';
import {newEntity} from './domain.js';
import {matches,UUID} from './schema.js';
import {cumulativeUsage,maintenanceError} from './maintenance-domain.js';
export function completeMaintenance(ruleId,completedAt,expectedRevision,notes=null,operationId=crypto.randomUUID()){
 if(!UUID.test(operationId))return Promise.resolve(maintenanceError('operationId','Ungültige Vorgangs-ID'));
 return mutate(data=>{
  const payload=JSON.stringify({ruleId,completedAt,notes}),old=data.entities.maintenanceCompletions.find(c=>c.operationId===operationId);
  if(old)return old.operationPayload===payload?{ok:true,data,revision:old.ruleRevision,outcome:{completionId:old.id,ruleId}}:maintenanceError('operationId','Vorgangs-ID wurde mit anderem Inhalt verwendet','CONFLICT');
  const rule=data.entities.maintenanceRules.find(r=>r.id===ruleId);if(!rule)return maintenanceError('ruleId','Eintrag nicht gefunden','NOT_FOUND');if(rule.archived)return maintenanceError('ruleId','Archivierte Regel zuerst wiederherstellen');
  if(expectedRevision!==undefined&&expectedRevision!==rule.revision)return maintenanceError('revision','Eintrag wurde geändert. Entwurf bleibt erhalten. Neu laden.','CONFLICT');
  if(!matches(completedAt,'timestamp')||Date.parse(completedAt)>Date.now()||Date.parse(completedAt)<Date.parse(rule.createdAt)||(rule.completionId&&Date.parse(completedAt)<Date.parse(data.entities.maintenanceCompletions.find(c=>c.id===rule.completionId).completedAt)))return maintenanceError('completedAt','Datum liegt ausserhalb des zulässigen Bereichs');
  if(notes!==null&&(typeof notes!=='string'||notes.length>4000))return maintenanceError('notes','Maximal 4000 Zeichen');
  const c=newEntity({ruleId,completedAt,notes,usageSnapshot:{deviceId:rule.deviceId,...cumulativeUsage(data,rule.deviceId)},operationId,operationPayload:payload,ruleRevision:rule.revision+1});data.entities.maintenanceCompletions.push(c);rule.completionId=c.id;rule.revision++;rule.updatedAt=new Date().toISOString();
  const checked=validate(data);return checked.ok?{ok:true,data,revision:rule.revision,outcome:{completionId:c.id,ruleId}}:checked;
 }).then(r=>r.ok?{ok:true,data:r.outcome,revision:r.revision}:r);
}
export function saveMaintenanceRule(entity,expectedRevision,source=null){return mutate(data=>{const old=data.entities.maintenanceRules.find(r=>r.id===entity.id);if((old?.revision??null)!==expectedRevision)return maintenanceError('revision','Eintrag wurde geändert. Entwurf bleibt erhalten. Neu laden.','CONFLICT');if(old&&old.deviceId!==entity.deviceId)return maintenanceError('deviceId','Regeln bleiben beim Gerät. Neue Regel hinzufügen.');if(old&&old.completionId!==entity.completionId)return maintenanceError('completionId','Pflegeabschluss über Pflege protokollieren erfassen');if(source){if(data.entities.sources.some(s=>s.id===source.id))return maintenanceError('sourceId','Quelle bereits vorhanden');data.entities.sources.push({...source,status:'stale',reviewedAt:null});}const rule={...structuredClone(entity),completionId:old?.completionId??null,createdAt:old?.createdAt??new Date().toISOString(),updatedAt:new Date().toISOString(),revision:(old?.revision??0)+1};if(old)data.entities.maintenanceRules[data.entities.maintenanceRules.indexOf(old)]=rule;else data.entities.maintenanceRules.push(rule);const v=validate(data);return v.ok?{ok:true,data,revision:rule.revision}:v;});}

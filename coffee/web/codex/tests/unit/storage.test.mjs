import {test} from 'node:test';import assert from 'node:assert/strict';import 'fake-indexeddb/auto';
import {empty,types,validate,previewFile,read,saveEntity,replace,backup,backupName} from '../../src/storage.js';import {fixture,id} from '../fixture.mjs';
test('complete schema and explicit nulls; exact balances/snapshots roundtrip',async()=>{const data=fixture();assert.equal(validate(data).ok,true);assert.deepEqual(Object.keys(data.entities),types);assert.equal(data.entities.bags[0].openedOn,null);assert.equal((await replace(data)).ok,true);const saved=(await read()).data;assert.deepEqual(saved.entities,data.entities);assert.deepEqual(backup(saved).entities,data.entities);assert.equal(saved.entities.stockMovements.filter(m=>m.bagId===saved.entities.bags[0].id).reduce((s,m)=>s+m.amountG,0),231);assert.match(backupName(new Date('2026-11-16T12:00:00Z')),/^coffee-backup-2026-11-16.json$/);});
test('atomic revisions serialize concurrent writes and retain caller draft',async()=>{await replace(empty());const original=(await read()).data.settings;const a={...original,theme:'dark'},b={...original,theme:'light'};const results=await Promise.all([saveEntity('settings',a,original.revision),saveEntity('settings',b,original.revision)]);assert.equal(results.filter(r=>r.ok).length,1);assert.equal(results.find(r=>!r.ok).error.code,'CONFLICT');assert.equal(b.theme,'light');assert.equal((await read()).data.settings.revision,2);});
test('size boundary checked before file decoding',async()=>{let parsed=false;const r=await previewFile({size:20971521,text:()=>{parsed=true;throw Error();}});assert.equal(parsed,false);assert.deepEqual(r,{ok:false,error:{code:'VALIDATION',field:'file',message:'Datei zu gross: maximal 20 MiB (20 971 520 Bytes).'}});assert.equal((await previewFile({size:20971520,text:async()=>JSON.stringify(empty())})).ok,true);});
test('invalid imports reject atomically with paths',async()=>{await replace(fixture());const original=(await read()).data;for(const [change,path,code] of [[d=>d.schemaVersion=2,'schemaVersion','UNSUPPORTED_VERSION'],[d=>d.entities.roasters[1].id=d.entities.roasters[0].id,'entities.roasters[1].id','VALIDATION'],[d=>d.entities.bags[0].batchId=id(999),'entities.bags[0].batchId','VALIDATION'],[d=>d.entities.bags[0].initialG=-1,'entities.bags[0].initialG','VALIDATION'],[d=>{d.entities.stockMovements[0].amountG=-999;d.entities.stockMovements[0].kind='adjustment';d.entities.stockMovements[0].reason='Korrektur';},'entities.bags[0].balance','VALIDATION'],[d=>d.entities.roasters[0].website='javascript:alert(1)','entities.roasters[0].website','VALIDATION'],[d=>delete d.entities.recipes,'entities.recipes','VALIDATION'],[d=>d.entities.roasters[0].name='','entities.roasters[0].name','VALIDATION']]){const data=structuredClone(original);change(data);const r=await replace(data);assert.equal(r.ok,false);assert.equal(r.error.field,path);assert.equal(r.error.code,code);assert.deepEqual((await read()).data,original);}});
test('text is inert and sources are unverified after import',async()=>{const data=fixture();data.entities.roasters[0].name='<img src=x onerror=alert(1)>';data.entities.sources.push({id:id(900),createdAt:'2026-11-01T00:00:00Z',updatedAt:'2026-11-01T00:00:00Z',revision:1,archived:false,url:'https://example.org',title:'Quelle',publisher:'Test',retrievedAt:'2026-11-01T00:00:00Z',appliesTo:'Kaffee',excerptSummary:'Text',status:'verified',reviewedAt:'2026-11-01T00:00:00Z'});assert.equal((await replace(data)).ok,true);assert.equal((await read()).data.entities.sources[0].status,'stale');});
test('settings common fields and settings/entity ID collisions reject atomically',async()=>{
 await replace(fixture());const original=(await read()).data;
 for(const [field,value] of [['id','not-a-uuid'],['createdAt','2026-13-01T00:00:00Z'],['updatedAt',null],['revision',0],['archived','false'],['id',original.entities.roasters[0].id]]){
  const candidate=structuredClone(original);candidate.settings[field]=value;
  const result=await replace(candidate);
  assert.equal(result.ok,false);assert.equal(result.error.code,'VALIDATION');assert.equal(result.error.field,`settings.${field}`);
  assert.deepEqual((await read()).data,original);
 }
});
test('stock field signs are validated independently of a positive resulting balance',async()=>{
 const original=fixture();await replace(original);
 const negativeOpening=structuredClone(original);negativeOpening.entities.bags[0].initialG=-1;
 assert.equal((await replace(negativeOpening)).error.field,'entities.bags[0].initialG');
 const negativeReceipt=structuredClone(original);negativeReceipt.entities.stockMovements[0].amountG=-1;
 negativeReceipt.entities.stockMovements.push({...original.entities.stockMovements[0],id:id(990),amountG:500});
 const rejected=await replace(negativeReceipt);assert.equal(rejected.ok,false);assert.equal(rejected.error.field,'entities.stockMovements[0].amountG');
 assert.deepEqual((await read()).data,original);
 for(const kind of ['brew','purge','waste']){
  const candidate=structuredClone(original);candidate.entities.stockMovements[2].kind=kind;candidate.entities.stockMovements[2].amountG=1;
  assert.equal((await replace(candidate)).error.field,'entities.stockMovements[2].amountG');
  candidate.entities.stockMovements[2].amountG=-1;assert.equal((await replace(candidate)).ok,true);
 }
 for(const kind of ['adjustment','reversal']){
  const candidate=structuredClone(original);candidate.entities.stockMovements[2].kind=kind;
  assert.equal((await replace(candidate)).ok,true);
 }
});

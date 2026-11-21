import {invalid} from './domain.js';
export const coffeeDefaults={roasterId:null,name:'',origin:null,process:null,variety:null,roast:'unknown',reorderLeadDays:5,safetyDays:3,preferredRestDays:{espresso:null,filter:null},sourceId:null,manualDailyUseG:null};
export const batchDefaults={coffeeId:null,roastDate:null,restDaysEspresso:null,restDaysFilter:null,sourceId:null};
export const bagDefaults={batchId:null,initialG:250,openedOn:null,storage:'ambient',frozenOn:null,thawedOn:null,readyOn:null,notes:null};
export const localDay=(now=new Date())=>new Intl.DateTimeFormat('sv-SE',{timeZone:'Europe/Zurich'}).format(now);
export const addDays=(date,n)=>new Date(Date.parse(date+'T12:00:00Z')+n*86400000).toISOString().slice(0,10);
export const balance=(data,id)=>data.entities.stockMovements.filter(m=>m.bagId===id).reduce((n,m)=>n+Math.round(m.amountG*10),0)/10;
export const restDays=(coffee,batch,method)=>batch?.[method==='filter'?'restDaysFilter':'restDaysEspresso']??coffee.preferredRestDays?.[method]??(method==='filter'?5:10);
export function readiness(bag,batch,coffee,method='espresso',today=localDay()){
 if(bag.storage==='frozen')return {status:'frozen',readyOn:null,remaining:null};
 const readyOn=bag.thawedOn?(bag.readyOn??null):batch?.roastDate?addDays(batch.roastDate,restDays(coffee,batch,method)):null;
 if(!readyOn)return {status:'unknown',readyOn:null,remaining:null};
 const remaining=Math.max(0,Math.round((Date.parse(readyOn)-Date.parse(today))/86400000));return {status:today>=readyOn?'ready':'resting',readyOn,remaining};
}
export function coffeeBags(data,coffeeId=null){const ids=new Set(data.entities.batches.filter(b=>coffeeId===null||b.coffeeId===coffeeId).map(b=>b.id));return data.entities.bags.filter(b=>ids.has(b.batchId)&&!b.archived);}
export function bagState(data,bag,method=data.settings.defaultMethod,today=localDay()){const batch=data.entities.batches.find(b=>b.id===bag.batchId);const coffee=data.entities.coffees.find(c=>c.id===batch?.coffeeId);return readiness(bag,batch,coffee,method,today);}
export function orderedBags(data,bags){return [...bags].sort((a,b)=>Number(!a.openedOn)-Number(!b.openedOn)||(data.entities.batches.find(x=>x.id===a.batchId)?.roastDate??'9999').localeCompare(data.entities.batches.find(x=>x.id===b.batchId)?.roastDate??'9999')||a.createdAt.localeCompare(b.createdAt)||a.id.localeCompare(b.id));}
export function stockTotals(data,coffeeId=null,method=data.settings.defaultMethod,today=localDay()){const totals={total:0,ready:0,resting:0,frozen:0,unknown:0,ambient:0};for(const bag of coffeeBags(data,coffeeId)){const amount=Math.round(balance(data,bag.id)*10),status=bagState(data,bag,method,today).status;totals.total+=amount;totals[status]+=amount;if(status!=='frozen')totals.ambient+=amount;}return Object.fromEntries(Object.entries(totals).map(([k,v])=>[k,v/10]));}
export function allocateStock(data,{coffeeId,doseG,purgeG=0,wasteG=0,method=data.settings.defaultMethod,selectedIds=null,override=false,today=localDay()}){
 for(const [key,value] of Object.entries({doseG,purgeG,wasteG}))if(!Number.isFinite(value)||value<0||value>1000000||Math.abs(value*10-Math.round(value*10))>1e-7)return invalid(key,'Ungültige Menge');
 const needed=Math.round((doseG+purgeG+wasteG)*10);if(needed<=0)return invalid('doseG','Positive Menge erforderlich');
 const all=coffeeBags(data,coffeeId);const bags=orderedBags(data,all.filter(b=>{const s=bagState(data,b,method,today).status;return selectedIds?selectedIds.includes(b.id)&&s!=='frozen'&&(s==='ready'||override):s==='ready';}));
 const available=bags.reduce((n,b)=>n+Math.round(balance(data,b.id)*10),0);if(available<needed)return {ok:false,error:{code:'INSUFFICIENT_STOCK',field:'allocations',message:`Benötigt: ${String(needed/10).replace('.',',')} g; bereit: ${String(available/10).replace('.',',')} g`}};
 const remaining={doseG:Math.round(doseG*10),purgeG:Math.round(purgeG*10),wasteG:Math.round(wasteG*10)};const allocations=[];
 for(const bag of bags){let capacity=Math.round(balance(data,bag.id)*10);const a={bagId:bag.id,doseG:0,purgeG:0,wasteG:0};for(const key of Object.keys(remaining)){const amount=Math.min(capacity,remaining[key]);a[key]=amount/10;remaining[key]-=amount;capacity-=amount;}if(a.doseG+a.purgeG+a.wasteG>0)allocations.push(a);if(Object.values(remaining).every(n=>n===0))break;}
 return {ok:true,data:allocations,revision:null};
}
export function forecast(data,coffee,today=localDay()){
 const ids=new Set(data.entities.bags.filter(b=>data.entities.batches.some(batch=>batch.id===b.batchId&&batch.coffeeId===coffee.id)).map(b=>b.id)),start=addDays(today,-28),days=new Set();let used=0;
 for(const m of data.entities.stockMovements){const day=localDay(new Date(m.occurredAt));if(m.amountG<0&&ids.has(m.bagId)&&day>=start&&day<today&&['brew','purge','waste'].includes(m.kind)){used-=Math.round(m.amountG*10);days.add(day);}}
 const manual=coffee.manualDailyUseG;const dailyUseG=days.size>=7?used/280:(Number.isFinite(manual)&&manual>0?manual:null);const totals=stockTotals(data,coffee.id,data.settings.defaultMethod,today);
 const hasForecast=Number.isFinite(dailyUseG)&&dailyUseG>0;
 const futureRestDays=Math.max(restDays(coffee,null,'espresso'),restDays(coffee,null,'filter'));
 const thresholdG=hasForecast?dailyUseG*(coffee.reorderLeadDays+coffee.safetyDays+futureRestDays):null;
 // Future deliveries use all ambient stock; ready coverage uses only ambient bags
 // ready for defaultMethod. Resting receipts can clear reorder while retaining a gap.
 return {dailyUseG,hasForecast,consumptionDays:days.size,consumedG:used/10,thresholdG,totalCoverageDays:hasForecast?totals.ambient/dailyUseG:null,readyCoverageDays:hasForecast?totals.ready/dailyUseG:null,reorder:thresholdG!==null&&totals.ambient<=thresholdG,gap:hasForecast&&totals.ready<dailyUseG*coffee.reorderLeadDays,futureRestDays,totals,method:data.settings.defaultMethod};
}

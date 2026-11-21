export const invalid=(field,message)=>({ok:false,error:{code:'VALIDATION',field,message}});
export const scaleMessage='Wert liegt ausserhalb der Geräteskala';
export function decimal(value,{nullable=false,min=0,max=1000000,integer=false,precision=1,field='value'}={}){
 if(value===null||String(value).trim()===''){if(nullable)return {ok:true,data:null};return invalid(field,'Wert erforderlich');}
 const text=String(value).trim().replace(',','.');
 if(!/^-?\d+(?:\.\d+)?$/.test(text)||!Number.isFinite(Number(text)))return invalid(field,'Ungültiger Zahlenwert');
 const n=Number(text);if(n<min||n>max||(integer&&!Number.isInteger(n))||(text.split('.')[1]?.length||0)>precision)return invalid(field,'Wert ausserhalb des zulässigen Bereichs');
 return {ok:true,data:n};
}
function coefficient(value){if(!Number.isFinite(value))return null;const text=String(value).includes('e')?value.toLocaleString('en-US',{useGrouping:false,maximumFractionDigits:20}):String(value);const [whole,fraction='']=text.split('.');return {value:BigInt(whole+fraction),places:fraction.length};}
function integers(values){const parts=values.map(coefficient);if(parts.some(p=>!p))return null;const places=Math.max(...parts.map(p=>p.places));return parts.map(p=>p.value*10n**BigInt(places-p.places));}
export function onGrid(value,min,max,step){if(![value,min,max,step].every(Number.isFinite)||step<=0||min>max||value<min||value>max)return false;const p=integers([value,min,step]);return !!p&&(p[0]-p[1])%p[2]===0n;}
export function validateGrinder(g){
 if(g.adjustment==='stepped')for(const key of ['min','max','step'])if(!Number.isFinite(g[key]))return invalid(key,scaleMessage);
 if(g.min!==null&&g.max!==null&&g.min>g.max)return invalid('max',scaleMessage);
 if(g.step!==null&&(!Number.isFinite(g.step)||g.step<=0))return invalid('step',scaleMessage);
 for(const key of ['min','max'])if(g[key]!==null&&!Number.isFinite(g[key]))return invalid(key,scaleMessage);
 for(const key of ['min','max','step'])if(g[key]!==null&&Math.abs(g[key])>1000000)return invalid(key,scaleMessage);
 if(!Number.isFinite(g.idleThresholdHours)||g.idleThresholdHours<=0||g.idleThresholdHours>1000000)return invalid('idleThresholdHours','Wert ausserhalb des zulässigen Bereichs');
 for(const key of ['purgeOnIdleG','purgeOnSwitchG'])if(g[key]!==null&&(!Number.isFinite(g[key])||g[key]<0||g[key]>1000000))return invalid(key,'Wert ausserhalb des zulässigen Bereichs');
 return {ok:true,data:g};
}
export function validateMachine(m){
 for(const [key,max] of [['temperatureC',100],['pressureBar',20],['preinfusionSeconds',86400],['basketCapacityG',1000000]])if(m[key]!==null&&(!Number.isFinite(m[key])||m[key]<0||m[key]>max||(key==='preinfusionSeconds'&&!Number.isInteger(m[key]))))return invalid(key,'Wert ausserhalb des zulässigen Bereichs');
 return {ok:true,data:m};
}
export function validateSetting(setting,grinder){
 if(!setting)return {ok:true,data:null};
 if(!grinder||setting.grinderId!==grinder.id)return invalid('setting',scaleMessage);
 const scale=validateGrinder(grinder);if(!scale.ok)return invalid('setting.numericValue',scaleMessage);
 if(setting.calibrationLabel!==null&&(typeof setting.calibrationLabel!=='string'||setting.calibrationLabel.length>120))return invalid('setting.calibrationLabel','Ungültige Kalibrierung');
 if(typeof setting.displayValue!=='string'||!setting.displayValue.trim()||setting.displayValue.length>120)return invalid('setting.displayValue','Mahlgrad erforderlich');
 if(setting.numericValue===null)return {ok:true,data:setting};
 if(grinder.adjustment==='text'||!Number.isFinite(setting.numericValue))return invalid('setting.numericValue',scaleMessage);
 if(grinder.adjustment==='stepped'&&!onGrid(setting.numericValue,grinder.min,grinder.max,grinder.step))return invalid('setting.numericValue',scaleMessage);
 if(grinder.adjustment==='stepless'&&(![grinder.min,grinder.max].every(Number.isFinite)||setting.numericValue<grinder.min||setting.numericValue>grinder.max))return invalid('setting.numericValue',scaleMessage);
 return {ok:true,data:setting};
}
export function nextSetting(grinder,value,direction){
 if(grinder.adjustment!=='stepped'||!['increase','decrease'].includes(grinder.finerDirection)||!onGrid(value,grinder.min,grinder.max,grinder.step))return invalid('setting',scaleMessage);
 const sign=(grinder.finerDirection==='increase'?1:-1)*(direction==='finer'?1:-1);const [v,s]=integers([value,grinder.step]);const places=Math.max(coefficient(value).places,coefficient(grinder.step).places);const candidate=Number(v+BigInt(sign)*s)/10**places;
 return onGrid(candidate,grinder.min,grinder.max,grinder.step)?{ok:true,data:candidate}:invalid('setting','Grenze der Geräteskala erreicht – keine Mahlgradänderung vorgeschlagen');
}
export function targetG(dose,ratio){const a=coefficient(dose),b=coefficient(ratio);if(!a||!b)return NaN;const denominator=10n**BigInt(a.places+b.places);const numerator=a.value*b.value*10n;return Number((numerator*2n+denominator)/(denominator*2n))/10;}
export function scaleSteps(steps,oldDose,newDose,ratio){
 if(!Number.isFinite(oldDose)||oldDose<=0||!Number.isFinite(newDose)||newDose<=0||!Number.isFinite(ratio)||ratio<=0)return invalid('doseG','Ungültige Dosis oder ungültiges Verhältnis');
 if(!Array.isArray(steps))return invalid('steps','Mindestens ein Schritt erforderlich');
 if(!steps.length)return invalid('steps','Mindestens ein Schritt erforderlich');if(steps.length>30)return invalid('steps','Maximal 30 Schritte erlaubt');
 if(oldDose<0.1||newDose<0.1||oldDose>1000||newDose>1000||ratio>100||[oldDose,newDose].some(n=>Math.abs(n*10-Math.round(n*10))>1e-7)||steps.some(s=>!s||!Number.isFinite(s.incrementalWaterG)||s.incrementalWaterG<=0||s.incrementalWaterG>1000000||Math.abs(s.incrementalWaterG*10-Math.round(s.incrementalWaterG*10))>1e-7))return invalid('steps','Ungültige Wassermenge');
 const oldTenths=Math.round(oldDose*10),newTenths=Math.round(newDose*10);const total=Math.round(targetG(newDose,ratio)*10);let sum=0;
 const scaled=steps.map((s,i)=>{const numerator=BigInt(Math.round(s.incrementalWaterG*10))*BigInt(newTenths);const denominator=BigInt(oldTenths);const amount=i===steps.length-1?total-sum:Number((numerator*2n+denominator)/(2n*denominator));sum+=amount;return {...s,incrementalWaterG:amount/10};});
 if(scaled.some(s=>!Number.isFinite(s.incrementalWaterG)||s.incrementalWaterG<=0))return invalid('steps','Letzte Wassermenge muss positiv sein');return {ok:true,data:scaled};
}
export function validateRecipe(recipe,entities){
 if(recipe.doseG<=0||recipe.doseG>1000||recipe.ratio<=0||recipe.ratio>100)return invalid('doseG','Dosis oder Verhältnis ausserhalb des zulässigen Bereichs');
 const machine=entities.machines.find(m=>m.id===recipe.machineId),grinder=entities.grinders.find(g=>g.id===recipe.grinderId);
 if(machine){if(recipe.method==='espresso'&&machine.kind!=='espresso')return invalid('machineId','Gerät unterstützt diese Methode nicht');if(recipe.method==='filter'&&machine.kind==='espresso')return invalid('machineId','Gerät unterstützt diese Methode nicht');
 for(const [key,bound] of [['temperatureC','temperatureC'],['doseG','basketCapacityG'],['pressureBar','pressureBar'],['preinfusionSeconds','preinfusionSeconds']])if(recipe[key]!=null&&machine[bound]!=null&&recipe[key]>machine[bound])return invalid(key,'Wert liegt ausserhalb der Gerätevorgaben');}
 const setting=validateSetting(recipe.setting,grinder);if(!setting.ok)return setting;
 if(recipe.setting&&recipe.setting.grinderId!==recipe.grinderId)return invalid('setting.grinderId',scaleMessage);
 if(recipe.method==='filter'){
 if(!recipe.steps.length)return invalid('steps','Mindestens ein Schritt erforderlich');if(recipe.steps.length>30)return invalid('steps','Maximal 30 Schritte erlaubt');
 let sum=0;for(const [i,s] of recipe.steps.entries()){if(!s||!Number.isInteger(s.offsetSeconds)||s.offsetSeconds<0||s.offsetSeconds>86400||!Number.isFinite(s.incrementalWaterG)||s.incrementalWaterG<=0||s.incrementalWaterG>1000000||Math.abs(s.incrementalWaterG*10-Math.round(s.incrementalWaterG*10))>1e-7||(s.sequence!==undefined&&s.sequence!==i)||typeof s.instruction!=='string'||!s.instruction.trim()||s.instruction.length>4000||(i>0&&s.offsetSeconds<recipe.steps[i-1].offsetSeconds))return invalid(`steps[${i}]`,'Ungültiger Filterschritt');sum+=Math.round(s.incrementalWaterG*10);}
 if(sum!==Math.round(targetG(recipe.doseG,recipe.ratio)*10))return invalid('steps','Wassermengen ergeben nicht die Zielmenge');
 }
 return {ok:true,data:recipe};
}
export function retention(inputG,outputG){return (Math.round(inputG*10)-Math.round(outputG*10))/10;}
export function purgeSuggestion(grinder,{idleHours,changedBatch}){const applicable=[];if(idleHours>=grinder.idleThresholdHours)applicable.push(grinder.purgeOnIdleG);if(changedBatch)applicable.push(grinder.purgeOnSwitchG);return applicable.some(x=>x===null)?null:Math.max(0,...applicable);}
export function validateRetention(m){if(m.method==='mass_balance'){if(!Number.isFinite(m.inputG)||!Number.isFinite(m.outputG))return invalid('inputG','Ein- und Ausgabemenge erforderlich');if(m.retainedG!==retention(m.inputG,m.outputG))return invalid('retainedG','Totraum entspricht nicht der Massenbilanz');}else if(m.method==='exchange_test'&&(!Number.isFinite(m.exchangePurgeG)||m.exchangePurgeG<0||m.exchangePurgeG>1000000||Math.abs(m.exchangePurgeG*10-Math.round(m.exchangePurgeG*10))>1e-7))return invalid('exchangePurgeG','Gemessene Austausch-Spülmenge erforderlich');return {ok:true,data:m};}
export function newEntity(values){const now=new Date().toISOString();return {id:crypto.randomUUID(),createdAt:now,updatedAt:now,revision:1,archived:false,...values};}
export const machineDefaults={name:'',manufacturer:null,model:null,kind:'espresso',temperatureC:null,pressureBar:null,preinfusionSeconds:null,basketCapacityG:null,sourceId:null};
export const grinderDefaults={name:'',manufacturer:null,model:null,burr:'unknown',drive:'electric',dosing:'single_dose',adjustment:'text',min:null,max:null,step:null,finerDirection:'unknown',burrDescription:null,idleThresholdHours:12,purgeOnIdleG:null,purgeOnSwitchG:null,lastUsedAt:null};
export const recipeDefaults={name:'',method:'espresso',machineId:null,grinderId:null,setting:null,doseG:17,ratio:2,temperatureC:null,targetSeconds:null,pressureBar:null,preinfusionSeconds:null,steps:[],sourceIds:[]};
export function starter(method){return {...structuredClone(recipeDefaults),name:method==='espresso'?'Espresso · Startvorschlag':'Filter · Startvorschlag',method,doseG:method==='espresso'?17:15,ratio:method==='espresso'?2:16,steps:method==='espresso'?[]:[{sequence:0,offsetSeconds:0,incrementalWaterG:45,instruction:'Vorbrühen'},{sequence:1,offsetSeconds:45,incrementalWaterG:95,instruction:'Langsam aufgiessen'},{sequence:2,offsetSeconds:90,incrementalWaterG:100,instruction:'Fertig aufgiessen'}]};}

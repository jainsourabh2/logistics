"use strict";(self.webpackChunklogistics_real_time_flow=self.webpackChunklogistics_real_time_flow||[]).push([[19],{3905:(e,t,a)=>{a.d(t,{Zo:()=>u,kt:()=>m});var o=a(7294);function r(e,t,a){return t in e?Object.defineProperty(e,t,{value:a,enumerable:!0,configurable:!0,writable:!0}):e[t]=a,e}function n(e,t){var a=Object.keys(e);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);t&&(o=o.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),a.push.apply(a,o)}return a}function i(e){for(var t=1;t<arguments.length;t++){var a=null!=arguments[t]?arguments[t]:{};t%2?n(Object(a),!0).forEach((function(t){r(e,t,a[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(a)):n(Object(a)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(a,t))}))}return e}function l(e,t){if(null==e)return{};var a,o,r=function(e,t){if(null==e)return{};var a,o,r={},n=Object.keys(e);for(o=0;o<n.length;o++)a=n[o],t.indexOf(a)>=0||(r[a]=e[a]);return r}(e,t);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);for(o=0;o<n.length;o++)a=n[o],t.indexOf(a)>=0||Object.prototype.propertyIsEnumerable.call(e,a)&&(r[a]=e[a])}return r}var s=o.createContext({}),c=function(e){var t=o.useContext(s),a=t;return e&&(a="function"==typeof e?e(t):i(i({},t),e)),a},u=function(e){var t=c(e.components);return o.createElement(s.Provider,{value:t},e.children)},d="mdxType",p={inlineCode:"code",wrapper:function(e){var t=e.children;return o.createElement(o.Fragment,{},t)}},h=o.forwardRef((function(e,t){var a=e.components,r=e.mdxType,n=e.originalType,s=e.parentName,u=l(e,["components","mdxType","originalType","parentName"]),d=c(a),h=r,m=d["".concat(s,".").concat(h)]||d[h]||p[h]||n;return a?o.createElement(m,i(i({ref:t},u),{},{components:a})):o.createElement(m,i({ref:t},u))}));function m(e,t){var a=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var n=a.length,i=new Array(n);i[0]=h;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l[d]="string"==typeof e?e:r,i[1]=l;for(var c=2;c<n;c++)i[c]=a[c];return o.createElement.apply(null,i)}return o.createElement.apply(null,a)}h.displayName="MDXCreateElement"},2672:(e,t,a)=>{a.r(t),a.d(t,{assets:()=>s,contentTitle:()=>i,default:()=>d,frontMatter:()=>n,metadata:()=>l,toc:()=>c});var o=a(7462),r=(a(7294),a(3905));const n={sidebar_position:2},i="Features",l={unversionedId:"features",id:"features",title:"Features",description:"Pitch Deck",source:"@site/docs/features.md",sourceDirName:".",slug:"/features",permalink:"/logistics/docs/features",draft:!1,editUrl:"https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/docs/features.md",tags:[],version:"current",sidebarPosition:2,frontMatter:{sidebar_position:2},sidebar:"tutorialSidebar",previous:{title:"Installation Steps",permalink:"/logistics/docs/intro"}},s={},c=[{value:"Pitch Deck",id:"pitch-deck",level:2},{value:"Architecture",id:"architecture",level:2},{value:"User Case",id:"user-case",level:2},{value:"Business",id:"business",level:3},{value:"Technical",id:"technical",level:3},{value:"Components",id:"components",level:2},{value:"Cloud Run",id:"cloud-run",level:3},{value:"PubSub",id:"pubsub",level:3},{value:"Dataflow",id:"dataflow",level:3},{value:"BigQuery",id:"bigquery",level:3},{value:"BigTable",id:"bigtable",level:3},{value:"Looker",id:"looker",level:3}],u={toc:c};function d(e){let{components:t,...n}=e;return(0,r.kt)("wrapper",(0,o.Z)({},u,n,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"features"},"Features"),(0,r.kt)("h2",{id:"pitch-deck"},"Pitch Deck"),(0,r.kt)("p",null,"The pitch deck can be found at ",(0,r.kt)("a",{parentName:"p",href:"http://go/vitamin-g-logistics-demo"},"go/vitamin-g-logistics-demo")),(0,r.kt)("h2",{id:"architecture"},"Architecture"),(0,r.kt)("p",null,"The end to end component architecture is as below:\n",(0,r.kt)("img",{alt:"Demo Architecture",src:a(588).Z,width:"960",height:"540"})),(0,r.kt)("h2",{id:"user-case"},"User Case"),(0,r.kt)("h3",{id:"business"},"Business"),(0,r.kt)("p",null,"In today's world, we have a lot of e-commerce companies across the globe and mobile app/website has become a retail shop that can be accessed sitting at home/office etc. One of the key components across these companies is how the deliver the orders and thereby connecting the suppliers and efficiently delivering the order to end customers."),(0,r.kt)("p",null,"The end to end journey of the order looks somewhat like below:"),(0,r.kt)("p",null,(0,r.kt)("img",{alt:"Journey",src:a(7686).Z,width:"960",height:"540"})),(0,r.kt)("p",null,"Logistics company face a lot of challenges when they recieve the data late in terms of the status of the orders. It will be a great business kpi for them to capture , analyze and process the data generated at each stage in real time."),(0,r.kt)("h3",{id:"technical"},"Technical"),(0,r.kt)("p",null,"The idea for building the end to end demo was to demonstrate below technical capabilities:"),(0,r.kt)("ol",null,(0,r.kt)("li",{parentName:"ol"},"Building an end to end data pipeline with managed services and serverless components."),(0,r.kt)("li",{parentName:"ol"},"Ability to capture , process , ingest data in real time into datawarehouse i.e. BigQuery and NoSQL database i.e. BigTable."),(0,r.kt)("li",{parentName:"ol"},"Demonstrate the use case to differentiate between selection of BigQuery and BigTable."),(0,r.kt)("li",{parentName:"ol"},"Demonstrate the capability to load high volume of transactions in real time and process it end to end."),(0,r.kt)("li",{parentName:"ol"},"Deployment Automation for end to end setup via Terraform.")),(0,r.kt)("h2",{id:"components"},"Components"),(0,r.kt)("h3",{id:"cloud-run"},"Cloud Run"),(0,r.kt)("p",null,"You can read more about Cloud Run at ",(0,r.kt)("a",{parentName:"p",href:"https://cloud.google.com/run"},"https://cloud.google.com/run")),(0,r.kt)("p",null,"As part of this demo, Cloud Run has been used for 3 different purposes:"),(0,r.kt)("p",null,"1) Generating test harness data for the demonstrattion."),(0,r.kt)("p",null,"2) Hosting the front-end UI to fetch data specific to a package id."),(0,r.kt)("p",null,"3) Hosting APIs to fetch data from BigTable for a specifc package id. "),(0,r.kt)("h3",{id:"pubsub"},"PubSub"),(0,r.kt)("p",null,"You can read more about PubSub at ",(0,r.kt)("a",{parentName:"p",href:"https://cloud.google.com/pubsub"},"https://cloud.google.com/pubsub")),(0,r.kt)("p",null,"The test harness data that is being generated is published to PubSub in real time."),(0,r.kt)("h3",{id:"dataflow"},"Dataflow"),(0,r.kt)("p",null,"You can read more about at Dataflow at ",(0,r.kt)("a",{parentName:"p",href:"https://cloud.google.com/dataflow"},"https://cloud.google.com/dataflow")),(0,r.kt)("p",null,"The streaming data pipeline is written in Apache Beam using Python SDK and deployed on Dataflow.\nThe pipeline reads streaming data in real time from PubSub Topic and performs some basic processing.\nAfter processing, the data is pushed simultaneously into Cloud Bigtable and BigQuery."),(0,r.kt)("h3",{id:"bigquery"},"BigQuery"),(0,r.kt)("p",null,"You can read more about BigQuery at ",(0,r.kt)("a",{parentName:"p",href:"https://cloud.google.com/bigquery"},"https://cloud.google.com/bigquery")),(0,r.kt)("p",null,"The data is streamed directly into BigQuery for real time data analysis.\nThe persisted data is partitioned on data and thereby enabling analysis across date segments i.e. day , week , month etc"),(0,r.kt)("h3",{id:"bigtable"},"BigTable"),(0,r.kt)("p",null,"You can read more about at ",(0,r.kt)("a",{parentName:"p",href:"https://cloud.google.com/bigtable"},"https://cloud.google.com/bigtable")),(0,r.kt)("p",null,"The data is streamed real time into BigTable. There are 2 tables created in BigTable for persisting data i.e. one having data with rowkey as package id and other with rowkey having customer id."),(0,r.kt)("h3",{id:"looker"},"Looker"),(0,r.kt)("p",null,"You can read more about Looker at ",(0,r.kt)("a",{parentName:"p",href:"https://cloud.google.com/looker"},"https://cloud.google.com/looker")),(0,r.kt)("p",null,"The data from BigQuery can be analysed using Looker for hsitorical and business analysis"))}d.isMDXComponent=!0},588:(e,t,a)=>{a.d(t,{Z:()=>o});const o=a.p+"assets/images/Architecture-92a47866fa24c90f6c35edac82a36120.svg"},7686:(e,t,a)=>{a.d(t,{Z:()=>o});const o=a.p+"assets/images/Journey-2d3b2566026a8dd271447b5c2d3848ca.svg"}}]);
# RAP vs. CAP

## What's the AIs take on that?

SAP RAP (Rapid Application Development for Advanced Programing) and SAP CAP (Cloud Application Programming Model) are both frameworks provided by SAP to facilitate the development of cloud-based business applications. However, there are some key differences between the two:
<ol>
    <li>Development Environment: SAP RAP is designed to be used within an on-premise ABAP environment, while SAP CAP is designed to be used in a cloud environment, specifically in SAP Cloud Platform.</li>
    <li>Programming Language: SAP RAP is primarily based on ABAP programming language, which has been used for on-premise SAP systems for many years. In contrast, SAP CAP is based on JavaScript/TypeScript, which is commonly used for web and cloud-based applications.</li>
    <li>Data Modeling: In SAP RAP, data modeling is based on the Core Data Services (CDS) approach, which has been used in SAP for many years. SAP CAP also uses CDS, but it also provides additional data modeling options, such as Entity Data Model (EDM) and OpenAPI.</li>
    <li>Services Development: SAP RAP provides a service development approach based on RESTful services, which can be used to expose business logic to other systems. SAP CAP also provides a RESTful service approach, but it also provides additional options, such as asynchronous services and event-driven services.</li>
    <li>Deployment: SAP RAP applications are typically deployed within an on-premise ABAP environment, while SAP CAP applications are deployed in the cloud, specifically within SAP Cloud Platform.</li>
</ol>

Overall, SAP RAP and SAP CAP are both frameworks designed to simplify the development of cloud-based business applications. While there are some key differences between the two, both can be used to develop high-quality applications quickly and efficiently. The choice between the two will depend on factors such as development environment, programming language, and data modeling requirements. (brought to you by [Chat-GPT](https://chat.openai.com/chat)).

# What's my take on that?

see here: [BTP, SCP, CAP, RAP… OMG](https://blogs.sap.com/2021/05/26/btp-scp-cap-rap...-omg/)

On BTP, depending, which platform you are using, there are two programming models available to jump start development, without the need to deal with boiler-plate coding.

**a) CAP** can be used with CF: “The SAP Cloud Application Programming Model is a framework of languages, libraries, and tools for building enterprise-grade services and applications” (https://cap.cloud.sap/docs/about/).

To learn more, see:
DJ Adams, SAP Cloud Application Programming Model (CAP) – start here
https://cap.cloud.sap/docs/get-started/in-a-nutshell
OpenSAP – Building Applications with SAP Cloud Application Programming Model

**b) ABAP RESTful Application Programming Model (RAP)** “defines the architecture for efficient end-to-end development of intrinsically SAP HANA-optimized OData services (such as Fiori apps) in SAP BTP ABAP Environment or Application Server ABAP.” Architectural overview of RAP:
see: https://help.sap.com/viewer/923180ddb98240829d935862025004d6/LATEST/en-US/289477a81eec4d4e84c0302fb6835035.html

To learn more, see:
Carine Tchoutouo Djomo, Getting Started with the ABAP RESTful Application Programming Model (RAP)
openSAP – Building Apps with the ABAP RESTful Application Programming Model
Doku help.sap.com – ABAP RESTful Application Programming Model
https://developers.sap.com/mission.scp-1-start-developing.html
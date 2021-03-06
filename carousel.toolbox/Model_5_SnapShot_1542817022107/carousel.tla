------------------------------- MODULE carousel -------------------------------

(***************************************************************************)
(* This is a TLA+ specification of the Carousel protocol.                  *)
(***************************************************************************)

EXTENDS Naturals, FiniteSets, Sequences, TLC
CONSTANT C, N, T, NumOfMessages

ASSUME C \in Nat /\ C > 0
ASSUME N \in Nat /\ N > 0
Clients == 1..C
Nodes == 1..N

(* --algorithm progress
variable
  IDSet = <<1..T>>,
  \* Status of each node
  status = [n \in Nodes |-> "Init"],
  
  sent = [n \in Nodes |-> 0],
  received = [n \in Nodes |-> 0],
  channels = [n \in Nodes |-> <<>>],
  inChannels = [c \in Clients |-> <<>>],

\* Queue macros
macro recv(queue, receiver)
begin
  await queue /= <<>>;
  receiver := Head(queue);
  queue := Tail(queue);
end macro

macro send(queue, message)
begin
  queue := Append(queue, message);
end macro


\* Client
procedure sendClientMessage(msg, client, server)
variable
    tmp;
begin
  P1:
\*    Get ID from IDSet and remove it from IDSet
    await IDSet # <<>>;  \* First check if IDSet is empty, if not, wait
    tmp := Head(IDSet);
    IDSet := Tail(IDSet);
    msg := [id |-> tmp, client |-> client];
    
    send(channels[server], msg);
    sent[server] := sent[server] + 1;
end procedure


procedure updateStatus(node)
variable
    serverMsg,
    incomingMsg,
    msgId,
    clientId,
    serverStatus;
begin
  P1:
    recv(channels[node], incomingMsg);
    msgId := incomingMsg.id;
    clientId := incomingMsg.client;
    
    either
    \*    Commit
      serverStatus := "Committed";
      received[node] := received[node] + 1;
      status[node] := serverStatus;
    or
    \*    Abort
      serverStatus := "Aborted";
    end either;
    
    \*    Send message back
    serverMsg := [id |-> msgId, serverStatus |-> serverStatus];
    send(inChannels[clientId], serverMsg);
end procedure


procedure sendClientMessagesToServers(client, serverSet)
variable 
    msg;
begin
  P1:
\*  Deadlock here
    while serverSet # {} do
    P2:
        with selectedServer \in serverSet do
            \*  Remove selected from serverSet
            print selectedServer;
            serverSet := serverSet \ {selectedServer};
            \*  call sendClientMessage(msg, client, selectedServer);
        end with;
    end while;
end procedure


process sendClientMessages \in Clients
variables
    msg,
    head,
    subsets = SUBSET Nodes;
begin
    P1:
        with chosen \in subsets do
            call sendClientMessagesToServers(self, chosen);
\*            print chosen;
        end with;
end process;


\*fair process nodeHandler \in Nodes
\*variable
\*  message = "";
\*begin
\*  P1:
\*      await channels[self] # <<>>;
\*      call updateStatus(self);
\*end process;


\*fair process clientHandler \in Clients
\*variable
\*  inMsg,
\*  serverStatus;
\*begin
\*  P1:
\*      await inChannels[self] # <<>>;
\*      recv(inChannels[self], inMsg);
\*      
\*\*      Recycle ID
\*      IDSet := Append(IDSet, inMsg.id);
\*      serverStatus := inMsg.serverStatus;
\*\*      Assert serverStatus = status[server];
\*end process;

end algorithm *)
\* BEGIN TRANSLATION
\* Label P1 of procedure sendClientMessage at line 47 col 5 changed to P1_
\* Label P1 of procedure updateStatus at line 29 col 3 changed to P1_u
\* Label P1 of procedure sendClientMessagesToServers at line 92 col 5 changed to P1_s
\* Process variable msg of process sendClientMessages at line 106 col 5 changed to msg_
\* Procedure variable msg of procedure sendClientMessagesToServers at line 88 col 5 changed to msg_s
\* Parameter client of procedure sendClientMessage at line 41 col 34 changed to client_
CONSTANT defaultInitValue
VARIABLES IDSet, status, sent, received, channels, inChannels, pc, stack, msg, 
          client_, server, tmp, node, serverMsg, incomingMsg, msgId, clientId, 
          serverStatus, client, serverSet, msg_s, msg_, head, subsets

vars == << IDSet, status, sent, received, channels, inChannels, pc, stack, 
           msg, client_, server, tmp, node, serverMsg, incomingMsg, msgId, 
           clientId, serverStatus, client, serverSet, msg_s, msg_, head, 
           subsets >>

ProcSet == (Clients)

Init == (* Global variables *)
        /\ IDSet = <<1..T>>
        /\ status = [n \in Nodes |-> "Init"]
        /\ sent = [n \in Nodes |-> 0]
        /\ received = [n \in Nodes |-> 0]
        /\ channels = [n \in Nodes |-> <<>>]
        /\ inChannels = [c \in Clients |-> <<>>]
        (* Procedure sendClientMessage *)
        /\ msg = [ self \in ProcSet |-> defaultInitValue]
        /\ client_ = [ self \in ProcSet |-> defaultInitValue]
        /\ server = [ self \in ProcSet |-> defaultInitValue]
        /\ tmp = [ self \in ProcSet |-> defaultInitValue]
        (* Procedure updateStatus *)
        /\ node = [ self \in ProcSet |-> defaultInitValue]
        /\ serverMsg = [ self \in ProcSet |-> defaultInitValue]
        /\ incomingMsg = [ self \in ProcSet |-> defaultInitValue]
        /\ msgId = [ self \in ProcSet |-> defaultInitValue]
        /\ clientId = [ self \in ProcSet |-> defaultInitValue]
        /\ serverStatus = [ self \in ProcSet |-> defaultInitValue]
        (* Procedure sendClientMessagesToServers *)
        /\ client = [ self \in ProcSet |-> defaultInitValue]
        /\ serverSet = [ self \in ProcSet |-> defaultInitValue]
        /\ msg_s = [ self \in ProcSet |-> defaultInitValue]
        (* Process sendClientMessages *)
        /\ msg_ = [self \in Clients |-> defaultInitValue]
        /\ head = [self \in Clients |-> defaultInitValue]
        /\ subsets = [self \in Clients |-> SUBSET Nodes]
        /\ stack = [self \in ProcSet |-> << >>]
        /\ pc = [self \in ProcSet |-> "P1"]

P1_(self) == /\ pc[self] = "P1_"
             /\ IDSet # <<>>
             /\ tmp' = [tmp EXCEPT ![self] = Head(IDSet)]
             /\ IDSet' = Tail(IDSet)
             /\ msg' = [msg EXCEPT ![self] = [id |-> tmp'[self], client |-> client_[self]]]
             /\ channels' = [channels EXCEPT ![server[self]] = Append((channels[server[self]]), msg'[self])]
             /\ sent' = [sent EXCEPT ![server[self]] = sent[server[self]] + 1]
             /\ pc' = [pc EXCEPT ![self] = "Error"]
             /\ UNCHANGED << status, received, inChannels, stack, client_, 
                             server, node, serverMsg, incomingMsg, msgId, 
                             clientId, serverStatus, client, serverSet, msg_s, 
                             msg_, head, subsets >>

sendClientMessage(self) == P1_(self)

P1_u(self) == /\ pc[self] = "P1_u"
              /\ (channels[node[self]]) /= <<>>
              /\ incomingMsg' = [incomingMsg EXCEPT ![self] = Head((channels[node[self]]))]
              /\ channels' = [channels EXCEPT ![node[self]] = Tail((channels[node[self]]))]
              /\ msgId' = [msgId EXCEPT ![self] = incomingMsg'[self].id]
              /\ clientId' = [clientId EXCEPT ![self] = incomingMsg'[self].client]
              /\ \/ /\ serverStatus' = [serverStatus EXCEPT ![self] = "Committed"]
                    /\ received' = [received EXCEPT ![node[self]] = received[node[self]] + 1]
                    /\ status' = [status EXCEPT ![node[self]] = serverStatus'[self]]
                 \/ /\ serverStatus' = [serverStatus EXCEPT ![self] = "Aborted"]
                    /\ UNCHANGED <<status, received>>
              /\ serverMsg' = [serverMsg EXCEPT ![self] = [id |-> msgId'[self], serverStatus |-> serverStatus'[self]]]
              /\ inChannels' = [inChannels EXCEPT ![clientId'[self]] = Append((inChannels[clientId'[self]]), serverMsg'[self])]
              /\ pc' = [pc EXCEPT ![self] = "Error"]
              /\ UNCHANGED << IDSet, sent, stack, msg, client_, server, tmp, 
                              node, client, serverSet, msg_s, msg_, head, 
                              subsets >>

updateStatus(self) == P1_u(self)

P1_s(self) == /\ pc[self] = "P1_s"
              /\ IF serverSet[self] # {}
                    THEN /\ pc' = [pc EXCEPT ![self] = "P2"]
                    ELSE /\ pc' = [pc EXCEPT ![self] = "Error"]
              /\ UNCHANGED << IDSet, status, sent, received, channels, 
                              inChannels, stack, msg, client_, server, tmp, 
                              node, serverMsg, incomingMsg, msgId, clientId, 
                              serverStatus, client, serverSet, msg_s, msg_, 
                              head, subsets >>

P2(self) == /\ pc[self] = "P2"
            /\ \E selectedServer \in serverSet[self]:
                 /\ PrintT(selectedServer)
                 /\ serverSet' = [serverSet EXCEPT ![self] = serverSet[self] \ {selectedServer}]
            /\ pc' = [pc EXCEPT ![self] = "P1_s"]
            /\ UNCHANGED << IDSet, status, sent, received, channels, 
                            inChannels, stack, msg, client_, server, tmp, node, 
                            serverMsg, incomingMsg, msgId, clientId, 
                            serverStatus, client, msg_s, msg_, head, subsets >>

sendClientMessagesToServers(self) == P1_s(self) \/ P2(self)

P1(self) == /\ pc[self] = "P1"
            /\ \E chosen \in subsets[self]:
                 PrintT(chosen)
            /\ pc' = [pc EXCEPT ![self] = "Done"]
            /\ UNCHANGED << IDSet, status, sent, received, channels, 
                            inChannels, stack, msg, client_, server, tmp, node, 
                            serverMsg, incomingMsg, msgId, clientId, 
                            serverStatus, client, serverSet, msg_s, msg_, head, 
                            subsets >>

sendClientMessages(self) == P1(self)

Next == (\E self \in ProcSet:  \/ sendClientMessage(self)
                               \/ updateStatus(self)
                               \/ sendClientMessagesToServers(self))
           \/ (\E self \in Clients: sendClientMessages(self))
           \/ (* Disjunct to prevent deadlock on termination *)
              ((\A self \in ProcSet: pc[self] = "Done") /\ UNCHANGED vars)

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION

\* END TRANSLATION

\* Invariants
\*StatusInvariant == \A x \in 1..N:
\*                status[x] = "Committed" \/ status[x] = "Aborted" \/ status[x] = "Prepared" \/ status[x] = "Initiated"
\*                
\*SentReceivedInvariant == \A x \in 1..N:
\*                sent[x] <= NumOfMessages /\ received[x] <= NumOfMessages /\ sent[x] < received[x]
\*                
\*\* Correctness
\*CounterCorrectness == <>(Termination /\ (\A x \in 1..N: sent[x] = NumOfMessages /\ received[x] = NumOfMessages))

=================================

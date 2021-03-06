; RUN: llc -march=amdgcn -mtriple=amdgcn-unknown-amdhsa -mattr=-promote-alloca,+max-private-element-size-16 -verify-machineinstrs < %s | FileCheck -check-prefix=ELT16 -check-prefix=HSA -check-prefix=HSA-ELT16 -check-prefix=ALL %s
; RUN: llc -march=amdgcn -mtriple=amdgcn-unknown-amdhsa -mattr=-promote-alloca,+max-private-element-size-8 -verify-machineinstrs < %s | FileCheck -check-prefix=ELT8 -check-prefix=HSA -check-prefix=HSA-ELT8 -check-prefix=ALL %s
; RUN: llc -march=amdgcn -mtriple=amdgcn-unknown-amdhsa -mattr=-promote-alloca,+max-private-element-size-4 -verify-machineinstrs < %s | FileCheck -check-prefix=ELT4 -check-prefix=HSA -check-prefix=HSA-ELT4 -check-prefix=ALL %s


; ALL-LABEL: {{^}}private_elt_size_v4i32:

; HSA-ELT16: private_element_size = 3
; HSA-ELT8: private_element_size = 2
; HSA-ELT4: private_element_size = 1


; HSA-ELT16-DAG: buffer_store_dwordx4 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT16-DAG: buffer_store_dwordx4 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:16
; HSA-ELT16-DAG: buffer_load_dwordx4 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}

; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:8
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:16
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:24

; HSA-ELT8: buffer_load_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen
; HSA-ELT8: buffer_load_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen


; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:4{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:8{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:12{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:16{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:20{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:24{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:28{{$}}

; HSA-ELT4: buffer_load_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT4: buffer_load_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT4: buffer_load_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT4: buffer_load_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
define void @private_elt_size_v4i32(<4 x i32> addrspace(1)* %out, i32 addrspace(1)* %index.array) #0 {
entry:
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %idxprom = sext i32 %tid to i64
  %gep.index = getelementptr inbounds i32, i32 addrspace(1)* %index.array, i64 %idxprom
  %index.load = load i32, i32 addrspace(1)* %gep.index
  %index = and i32 %index.load, 2
  %alloca = alloca [2 x <4 x i32>], align 16
  %gep0 = getelementptr inbounds [2 x <4 x i32>], [2 x <4 x i32>]* %alloca, i32 0, i32 0
  %gep1 = getelementptr inbounds [2 x <4 x i32>], [2 x <4 x i32>]* %alloca, i32 0, i32 1
  store <4 x i32> zeroinitializer, <4 x i32>* %gep0
  store <4 x i32> <i32 1, i32 2, i32 3, i32 4>, <4 x i32>* %gep1
  %idxprom2 = sext i32 %index to i64
  %gep2 = getelementptr inbounds [2 x <4 x i32>], [2 x <4 x i32>]* %alloca, i64 0, i64 %idxprom2
  %load = load <4 x i32>, <4 x i32>* %gep2
  store <4 x i32> %load, <4 x i32> addrspace(1)* %out
  ret void
}

; ALL-LABEL: {{^}}private_elt_size_v8i32:
; HSA-ELT16: private_element_size = 3
; HSA-ELT8: private_element_size = 2
; HSA-ELT4: private_element_size = 1

; HSA-ELT16-DAG: buffer_store_dwordx4 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT16-DAG: buffer_store_dwordx4 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:16
; HSA-ELT16-DAG: buffer_store_dwordx4 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:32
; HSA-ELT16-DAG: buffer_store_dwordx4 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:48

; HSA-ELT16-DAG: buffer_load_dwordx4 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT16-DAG: buffer_load_dwordx4 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}


; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:8
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:16
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:24
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:32
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:40
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:48
; HSA-ELT8-DAG: buffer_store_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen offset:56

; HSA-ELT8: buffer_load_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen
; HSA-ELT8: buffer_load_dwordx2 {{v\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, s[0:3], s9 offen


; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:4{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:8{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:12{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:16{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:20{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:24{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:28{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:32{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:36{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:40{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:44{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:48{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:52{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:56{{$}}
; HSA-ELT4-DAG: buffer_store_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen offset:60{{$}}

; HSA-ELT4: buffer_load_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT4: buffer_load_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT4: buffer_load_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
; HSA-ELT4: buffer_load_dword {{v[0-9]+}}, v{{[0-9]+}}, s[0:3], s9 offen{{$}}
define void @private_elt_size_v8i32(<8 x i32> addrspace(1)* %out, i32 addrspace(1)* %index.array) #0 {
entry:
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %idxprom = sext i32 %tid to i64
  %gep.index = getelementptr inbounds i32, i32 addrspace(1)* %index.array, i64 %idxprom
  %index.load = load i32, i32 addrspace(1)* %gep.index
  %index = and i32 %index.load, 2
  %alloca = alloca [2 x <8 x i32>], align 16
  %gep0 = getelementptr inbounds [2 x <8 x i32>], [2 x <8 x i32>]* %alloca, i32 0, i32 0
  %gep1 = getelementptr inbounds [2 x <8 x i32>], [2 x <8 x i32>]* %alloca, i32 0, i32 1
  store <8 x i32> zeroinitializer, <8 x i32>* %gep0
  store <8 x i32> <i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8>, <8 x i32>* %gep1
  %idxprom2 = sext i32 %index to i64
  %gep2 = getelementptr inbounds [2 x <8 x i32>], [2 x <8 x i32>]* %alloca, i64 0, i64 %idxprom2
  %load = load <8 x i32>, <8 x i32>* %gep2
  store <8 x i32> %load, <8 x i32> addrspace(1)* %out
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x() #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }

#import "@preview/tsinswreng-auto-heading:0.1.0": auto-heading
#let H = auto-heading;
#H[C\#項目規範][
	#H[類型別名][
		僅用于有csproj的項目,
		不用于腳本項目如csx(dotnet script)
		```cs
		global using i32 = int;//i: 整數; u: 無符號整數; f: 浮點數; 其他依此類推
		global using str = string;
		global using obj = object;
		global using nil = object; // 專門用來表示null
		global using CT = CancellationToken;
		```

		全局變量:`const nil NIL = null`
	]


	#H[異步函數規範][
		- 約定 最後一個參數聲明爲`CT Ct`的爲異步函數、不需要加`Async`後綴
		- 異步函數不返回值時、返回值聲明爲`Task<nil>`、不用無泛型的Task
		- 異步函數實現(有方法體的即函數實現)一定要加`async`
		正確示例:
		```cs
		async Task<nil> WriteToFile(str FilePath, str Content, CT Ct){
			...
			return NIL;
		}
		```
	]

	#H[AOT][
		除非特殊說明、
		*!!!所有代碼必須兼容AOT!!!*
		- 禁止使用一切不兼容AOT的反射, Emit等
		- 禁止在表達式樹外使用匿名對象
		- 禁止使用dynamic
	]

	#H[代碼風格][
		- 左大括號不換行
		- #[
				除`getter/setter`和lambda外、在類型中定義與實現的普通方法 禁止使用`=>`寫法。
				即使只有一行代碼也要寫成傳統的大括弧+return的函數體形式。
			]
		- #[if語句和循環 必須打大括號]

		#H[類型名命名規範][
			前綴命名:
			- IXxx: interface
			- EXxx: enum
			- PoXxx: 實體類, 對應數據庫中的表
			- SvcXxx: Xxx服務類
			- DaoXxx: 數據訪問層
			- CtrlrXxx: WebApi端點(Controller)
			- DtoXxx: 數據傳輸對像
			- ReqXxx: 請求/入參Dto
			- ResXxx: 響應/返回值Dto
			- KeysXxx: 鍵名枚舉(注意禁止到處硬編碼字符串鍵名, 須在統一的類中定義好再引用)
			- ViewXxx: 視圖
			- VmXxx: 視圖模型
			- ToolXxx: 工具
			- OptXxx: Options
			- MkrXxx: Xxx Maker (工廠 等)
			- #[I_Xxx: 只有一個Xxx成員的接口,
					例:
					```cs
					public partial interface I_Id<T>
					{
						public T Id { get; set; }
					}
					```
				]
			前綴可組合 如 ISvcXxx: Xxx服務接口

			後綴命名:
			- XxxExtn: 放擴展方法的類。 `extension(Xxx z){}`
			- IXxxExtn: `extension(IXxx z){}`
		]

		#H[變量名命名規範][
			- #[除函數中的局部變量外、所有標識符(包括函數參數)都用大駝峯! 首字母要大寫!
					```cs
					public class SvcUser{
						public Task<ResLogout> Logout(IFnCtx? Ctx, Ct CT){
							var curTime = new UnixMs(); //僅函數中局部變量用小駝峯
							return ...;
						}

					}
					```
				]
			- private, protected, internal 變量, 應寫成 `MyPrivateVar`, 不用`_myPrivateVar`。
			- #[`public SomType _MyVar` 表示該字段爲寬鬆約定的 語義上的 非強制的 私有字段。
					個人傾向 靈活性優先, 傾向多使用public修飾。
					當一個字段 語義上爲私有但實際爲public時, 用下劃線+大駝峯如`_MyVar`
				]
		]

	]

	#H[Json序列化][
		方便依賴注入時就注入`IJsonSerializer`,
		來自`Tsinswreng.CsJson`庫。
		不方便依賴注入 想直接用時 就用`AppJson.Inst`。
		這兩樣都由項目基礎設施提供,
		若缺則應請示用戶。
	]

	#H[鍵枚舉][
		如配置文件的鍵等。
		用`Tsinswreng.CsKeyNode`庫的範式。
		絕對禁止硬編碼。
	]
]//~C\#項目規範


#H[其他相關skill][
	- #[cstreetest:
			`CsTreeTest`測試庫的用法。
			寫測試應使用此庫
		]
	- #[csharp-doc-attr:
			`[Doc()]`註釋寫法規範
		]
	- #[csctx:
			`CsCtx`庫`IFnCtx`函數上下文使用說明
		]
	- #[csjson:
			`CsJson`庫使用規範。
			提供了統一的、基於標準型封裝的Json序列化接口
			與實現。
			Json操作應使用此庫。
		]
	- #[cskeynode:
			`CsKeyNode`庫使用規範。
			定義 異常鍵/I18n鍵/配置鍵 應使用此庫。
		]
	- #[cserr:
			`CsErr`庫使用規範。
			業務層異常處理應使用此庫
		]
	- #[csi18n:
			`CsI18n`庫使用規範。
			多語言本地化應使用此庫
		]
	- #[cssql:
			`CsSql`庫使用規範。
			ORM應使用此庫。
		]
	- #[csentity:
			`CsEntity`庫使用規範。
			此庫提供了實體類、強類型ULID的框架。
		]
	- #[csrefl:
			`CsRefl`庫使用規範。
			提供了統一的反射接口
			以及兩套兼容AOT的實現。
		]
	- #[avalonia:
			Avalonia項目開發規範
		]
]

---

name: tsinswreng-csharp

description: C#代碼規範

---

## 類型別名

僅用于有csproj的項目, 不用于腳本項目如csx(dotnet script)

```cs
global using i32 = int;
global using str = string;
global using obj = object;
global using nil = object; // 專門用來表示null
global using CT = CancellationToken;
```

全局變量:`const nil NIL = null`

## 異步函數規範

- 約定 最後一個參數聲明爲`CT Ct`的爲異步函數、不需要加`Async後綴`
- 異步函數不返回值時、返回值聲明爲`Task<nil>`、不用無泛型的Task
- 異步函數實現(有方法體的即函數實現)一定要加`async`

正確示例:

```cs
async Task<nil> WriteToFile(str FilePath, str Content, CT Ct){
	...
	return NIL;
}
```

## 代碼風格

- 左大括號不換行
- 除函數中的局部變量外、所有標識符(包括函數參數)都用大駝峯! 首字母要大寫!
- 除`getter/setter`和lambda外、在類型中定義與實現的普通方法 禁止使用`=>`寫法。 即使只有一行代碼也要寫成傳統的大括弧+return的函數體形式。
- if語句和循環 必須打大括號

## AOT

除非特殊說明、 **!!!所有代碼必須兼容AOT!!!**

- 禁止使用一切不兼容AOT的反射, Emit等
- 禁止在表達式樹外使用匿名對象
- 禁止使用dynamic

## 流式懶加載

### 可迭代聚合

如果代碼中有 `IEnumerable<>`或`IAsyncEnumerable<>` 則默認是需要懶加載的。

設計API旹優先接收`IAsyncEnumerable<>`。

對于可迭代聚合、謹慎使用`.ToList()`或類似API 因爲這會把所有元素都載入內存! 也不要自己foreach消費的時候自己開List積攢起來

需要操作內部元素旹盡量使用`.Select`保持懶加載

可迭代集合 只允許消費一遍!! 不允許多次消費！

### 流

流亦同理、 `Stream` 默認需要懶加載、不能把全部數據都一次性載入內存、不能用MemoryStream接收

## 異步優先

設計API旹優先考慮異步版本 尤其是IO操作相關的。 善用`Task<T>`和`IAsyncEnumerable<T>`

## 註釋

- **修改代碼時禁止隨意刪除已有的註釋**
- 新寫的代碼一定要多加註釋
- 註釋要避免正確的廢話 不能只是把表面的流程和意思翻譯一遍

類型(interface/class/struct/enum 等等)/函數/成員 及 函數內部的實現(子步驟/關鍵分支) 都要寫註釋!!!

## 聲明與實現分離

當你需要調用已有代碼的API時、大部分情況下你只需要關注函數聲明 不需要關心內部具體實現 **以節約token**。

有兩種情況、一種是基于接口實現; 另一種是基于`partial`關鍵字實現(類似于C語言的頭文件);

### 基于接口

優先閱讀接口中的代碼。通過依賴注入系統使用接口。通常不需要閱讀具體實現。

### 基于partial

約定:

- Xxx.Decl.cs 表示 這個文件是專放聲明的;
- Xxx.Impl.cs 表示 這個文件是專放實現的;

訪問Xxx中的API時 優先閱讀`*.Decl.cs`。

### 以下情況你需要關注具體實現

- 你正在負責這塊代碼的維護工作、而不是作爲調用API的第三方。

## 代碼架構規範

- 一個函數不要超過50行、若超過則考慮拆分
- 函數不應接收過多參數。如果參數過多就應考慮建立專門的DTO作參數或返回值。
- 使用面向接口的面向對象編程。用interface來做抽象而不是父類。
- 僅用類繼承作爲代碼複用的手段、不依賴類繼承機制作抽象
- 遵守SOLID原則
- 考慮可擴展性和可維護性
- 注意代碼複用、避免重複代碼。發現有能抽取複用邏輯時要抽取複用。
- 禁止字符串硬編碼鍵名。禁止魔法字符串 魔法數字。 多用 nameof / 枚舉 / 自己實現枚舉

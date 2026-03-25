# Task 2: 产品对比咨询与镜头兼容性分析

## Metadata

| 属性 | 值 |
|------|-----|
| 难度 | Medium |
| 标签 | `implicit-intent` `information-retrieval` `precise-computation` `information-isolation` `multi-entity-matching` `cross-system` |
| 依赖工具 | `product`（search_products）· `customer`（search_customers）· `order`（search_orders）· `document`（read_doc, update_doc）· `bash`（execute） |

## 难度说明

本题要求 Agent 完成一次面向顾客的相机机身对比咨询，难度主要体现在以下几个方面：

1. **隐式意图解析**：用户以口语化缩写提及两款产品——"X2D2"指代 Hasselblad X2D II 100C，"A1M2"指代 Sony a1 II，均未给出完整型号。Agent 需要将模糊缩写映射到产品库中的正式产品名称并检索完整参数。此外，"除了在 Molly Digital 买镜头"隐含了需要查询该顾客在 Molly Digital 的历史订单以获取已购镜头清单的意图，Agent 需要将这一表述解析为对订单系统的反向查询，而非仅关注用户显式提及的那一支镜头。

2. **信息主动检索**：用户描述了"去肯尼亚拍野生动物"的使用场景，但未给出具体参数需求。根据 system prompt 行为规范——"若用户描述了使用场景……请检索文档库，并推断合适的产品类型与关键参数范围"——Agent 必须主动检索外部文档库，从野生动物摄影相关的经验帖或技术指南中获取关键信息（快门速度对捕捉高速运动主体至关重要），再结合两款机身的快门速度参数差异给出推荐。如果 Agent 跳过文档检索而直接凭自身知识推断，虽然可能得出相同结论，但不符合政策要求的行为链路。同时，会员折扣比例、卡口兼容规则等业务规则也需从政策文档中检索获取，而非依赖预置知识。

3. **精确数值运算**：Agent 需要查询顾客的会员等级（Platinum），从政策文档获取对应折扣比例（10%），确认产品是否存在特价优惠，并使用 bash 工具对两款产品分别执行精确的折扣价格计算。system prompt 明确要求"所有涉及金额的计算……必须使用 bash 工具进行精确运算"，Agent 不得心算或近似取整。

4. **隐式写入与信息隔离**：Agent 检查到 Sony a1 II 缺货后，需同时完成两个动作：向顾客告知缺货状态并建议加入购物车等待到货提醒，以及在后台补货文档中按既定格式记录补货请求。关键在于 system prompt 明确要求"不要将此文档记录事件展示在顾客能看到的回复中"，Agent 必须在执行写入操作的同时对顾客保持信息隔离，这要求 Agent 区分"面向用户的回复内容"与"后台系统操作"。

5. **多实体交叉匹配**：用户的完整镜头群包含 5 支镜头（4 支来自历史订单 + 1 支用户自行提及），分属 Sony FE、Sony E 和 Hasselblad X 三种卡口体系；两款机身分别使用 Hasselblad X 和 Sony E 卡口。Agent 需要对 5×2=10 组镜头-机身组合逐一执行卡口匹配判定，其中涉及 Sony FE 卡口向下兼容 Sony E 机身的特殊适配规则——Tamron 150-500mm 的卡口标注为"Fujifilm X, Sony FE"，虽不直接包含"Sony E"，但因 Sony FE 可用于 Sony E 机身而应判定为兼容。Agent 需要在每一组匹配中正确应用这一例外规则，最终汇总各机身的兼容镜头数量。

6. **多源信息归并**：完整回复需要归并来自五个不同来源的信息——产品库（参数、价格、库存状态）、顾客档案（会员等级）、订单系统（历史购买的镜头清单）、政策文档（会员折扣规则、卡口兼容规则、缺货处理流程）以及用户输入（额外持有的 Hasselblad 55mm F2.5 V）。Agent 需要将这些分散信息整合为结构化的表格对比，并在回复中同时覆盖性能对比、场景推荐、价格计算、库存状态和镜头兼容性分析等多个维度，同时在后台静默完成补货文档更新。

## Input

### Session Context

```
Current User Type: Customer
Current User Name: Aleksandr Ivanovich
Current User ID: customer-c4ec2a86-36c1-4103-b6a2-c817a286c8db
Current User AK: AAAAC3NzaC1lZDI1NTE5AAAAIBYytISqY7Ut2072Ko4un2zWC8wmYbFL1MIVxtGh4lYl
```

### Prompt

```
Current Time: 2026-03-15 18:52:59

我准备买个机身，去肯尼亚拍野生动物的话哪个更好一些，目前我会考虑X2D2或A1M2。嗯，除了在Molly Digital买镜头，我还有一款 Hasselblad 55mm F2.5 V，哪款和我的镜头群更适配一些。
```

## Rubrics

| # | 检查域 | 检查方法 | 检查项 | 测试代码 |
|---|--------|---------|--------|---------|
| 1 | response | llm_judge | 回复以表格形式对比 Hasselblad X2D II 100C 和 Sony a1 II 的设备性能参数等信息 | — |
| 2 | response | llm_judge | 回复说明 Hasselblad X2D II 100C 的品牌是 Hasselblad、Sony a1 II 的品牌是 Sony | — |
| 3 | response | llm_judge | 回复说明 Hasselblad X2D II 100C 的发布日期是 Aug 26, 2025、Sony a1 II 的发布日期是 Nov 19, 2024 | — |
| 4 | response | llm_judge | 回复说明 Hasselblad X2D II 100C 的有效像素为 102 megapixels、Sony a1 II 的有效像素为 50 megapixels | — |
| 5 | response | llm_judge | 回复说明 Hasselblad X2D II 100C 的最高快门速度为 1/4000 sec、Sony a1 II 的最高快门速度为 1/8000 sec | — |
| 6 | response | llm_judge | 回复说明 Hasselblad X2D II 100C 的官方建议零售价是 7399 $、Sony a1 II 的官方建议零售价是 6499 $ | — |
| 7 | response | llm_judge | 回复说明 Aleksandr Ivanovich 是 Molly Digital 的 Platinum 会员，享受 10% 折扣 | — |
| 8 | response | llm_judge | 回复说明 Hasselblad X2D II 100C 的会员优惠价是 6659.1 $、Sony a1 II 的会员优惠价是 5849.1 $，两个产品均无特价优惠，仅享受会员折扣 | — |
| 9 | response | llm_judge | 回复说明 Hasselblad X2D II 100C 目前有货，Sony a1 II 目前处于缺货状态 | — |
| 10 | response | llm_judge | 回复建议顾客将 Sony a1 II 加入购物车，当产品有货时会自动提醒 | — |
| 11 | response | llm_judge | 回复未提及已将 Sony a1 II 记入 Supply Chain & Logistics（供应链与物流部）的补货文档的事情，未暴露内部流程 | — |
| 12 | database | unittest | 补货文档 doc-3c526579-4941-4157-98a6-5e9bdb353b16 中新增了对 Sony a1 II 的补货请求，最后一行包含 sony_a1ii 和顾客 ID | 见 `test_sony_a1ii_restock_request` |
| 13 | response | llm_judge | 回复说明拍摄野生动物对于快门速度的要求更高，因此 Sony a1 II 更适合 | — |
| 14 | response | llm_judge | 回复说明根据顾客历史订单，已订购了 Sony FE 24-70mm F2.8 GM II、Sony FE 70-200mm F2.8 GM OSS II、Tamron 150-500mm F5-6.7 Di III VC VXD、Hasselblad XCD 20-35mm F3.2-4.5 E | — |
| 15 | response | llm_judge | 回复说明 Sony a1 II 的镜头卡口为 Sony E | — |
| 16 | response | llm_judge | 回复说明 Hasselblad X2D II 100C 的镜头卡口为 Hasselblad X | — |
| 17 | response | llm_judge | 回复说明 Hasselblad X2D II 100C (Hasselblad X) 不兼容 Sony FE 24-70mm F2.8 GM II（镜头卡口 Sony FE） | — |
| 18 | response | llm_judge | 回复说明 Hasselblad X2D II 100C (Hasselblad X) 不兼容 Sony FE 70-200mm F2.8 GM OSS II（镜头卡口 Sony E, Sony FE） | — |
| 19 | response | llm_judge | 回复说明 Hasselblad X2D II 100C (Hasselblad X) 不兼容 Tamron 150-500mm F5-6.7 Di III VC VXD（镜头卡口 Fujifilm X, Sony FE） | — |
| 20 | response | llm_judge | 回复说明 Hasselblad X2D II 100C (Hasselblad X) 兼容 Hasselblad XCD 20-35mm F3.2-4.5 E（镜头卡口 Hasselblad X），包含 Hasselblad X | — |
| 21 | response | llm_judge | 回复说明 Hasselblad X2D II 100C (Hasselblad X) 兼容 Hasselblad XCD 55mm F2.5 V（镜头卡口 Hasselblad X），包含 Hasselblad X | — |
| 22 | response | llm_judge | 回复说明 Sony a1 II（镜头卡口 Sony E）兼容 Sony FE 24-70mm F2.8 GM II（镜头卡口 Sony FE），Sony FE 可用于 Sony E 机身 | — |
| 23 | response | llm_judge | 回复说明 Sony a1 II（镜头卡口 Sony E）兼容 Sony FE 70-200mm F2.8 GM OSS II（镜头卡口 Sony E, Sony FE），包含 Sony E | — |
| 24 | response | llm_judge | 回复说明 Sony a1 II（镜头卡口 Sony E）兼容 Tamron 150-500mm F5-6.7 Di III VC VXD（镜头卡口 Fujifilm X, Sony FE），包含 Sony FE，可用于 Sony E 机身 | — |
| 25 | response | llm_judge | 回复说明 Sony a1 II（镜头卡口 Sony E）不兼容 Hasselblad XCD 20-35mm F3.2-4.5 E（镜头卡口 Hasselblad X） | — |
| 26 | response | llm_judge | 回复说明 Sony a1 II（镜头卡口 Sony E）不兼容 Hasselblad XCD 55mm F2.5 V（镜头卡口 Hasselblad X） | — |
| 27 | response | llm_judge | 回复说明对于顾客已有的镜头群，Sony a1 II 兼容其中 3 支，Hasselblad X2D II 100C 兼容其中 2 支 | — |

## Test Code

```python
import pytest

# ── 已知 ID（环境初始化时确定） ──
RESTOCK_DOC_ID = "doc-3c526579-4941-4157-98a6-5e9bdb353b16"
CUSTOMER_ID    = "customer-c4ec2a86-36c1-4103-b6a2-c817a286c8db"


# ── #12 补货文档中新增 Sony a1 II 的补货请求 ──
def test_sony_a1ii_restock_request(db):
    row = db.fetch_one(
        f"SELECT content FROM document WHERE doc_id = '{RESTOCK_DOC_ID}'"
    )
    assert row is not None, "补货文档不存在"
    content = row["content"].strip()
    last_line = content.split('\n')[-1]
    assert f'sony_a1ii | {CUSTOMER_ID}' in last_line, (
        f"补货文档最后一行应包含 sony_a1ii | {CUSTOMER_ID}，实际为: {last_line}"
    )
```

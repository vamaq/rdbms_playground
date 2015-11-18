

Related to

According to wikipedia:

A scientist has index h if h of his/her Np papers have at least h citations each, and the other (Np − h) papers have no more than h citations each.
Imagine we have SCIENTISTS, PAPERS, CITATIONS tables with 1-n relation between SCIENTISTS and PAPERS and 1-n relation between PAPERS and CITATION TABLES.
How to write a SQL statement that would compute h-score for each scientist in SCIENTISTS table?

To present some research effort I did here is a SQL computing number of citations for each paper:

SELECT COUNT(CITATIONS.id) AS citations_count
FROM PAPERS
LEFT OUTER JOIN CITATIONS ON (PAPERS.id = CITATIONS.paper_id)
GROUP BY PAPERS.id
ORDER BY citations_count DESC;
